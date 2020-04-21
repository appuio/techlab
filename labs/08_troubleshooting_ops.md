# Lab 8: Troubleshooting

In diesem Lab wird aufgezeigt, wie man im Fehlerfall vorgehen kann und welche Tools einem dabei zur Verfügung stehen.

## In Container einloggen

Wir verwenden dafür das Projekt aus [Lab 4](04_deploy_dockerimage.md) `[USERNAME]-dockerimage`.

<details><summary><b>Tipp</b></summary>oc project [USERNAME]-dockerimage</details><br/>

Laufende Container werden als unveränderbare Infrastruktur behandelt und sollen generell nicht modifiziert werden.
Dennoch gibt es Usecases, bei denen man sich in die Container einloggen muss.
Zum Beispiel für Debugging und Analysen.

## Aufgabe 1: Remote Shells

Mit OpenShift können Remote Shells in die Pods geöffnet werden, ohne dass man darin vorgängig SSH installieren müsste.
Dafür steht einem der Befehl `oc rsh` zur Verfügung.

Wählen Sie einen Pod aus und öffnen Sie die Remote Shell.

<details><summary><b>Tipp</b></summary>oc get pods<br/>oc rsh [POD]</details><br/>

Sie können nun über diese Shell Analysen im Container ausführen:

```bash
bash-4.2$ ls -la
total 16
drwxr-xr-x. 7 default root   99 May 16 13:35 .
drwxr-xr-x. 4 default root   54 May 16 13:36 ..
drwxr-xr-x. 6 default root   57 May 16 13:35 .gradle
drwxr-xr-x. 3 default root   18 May 16 12:26 .pki
drwxr-xr-x. 9 default root 4096 May 16 13:35 build
-rw-r--r--. 1 root    root 1145 May 16 13:33 build.gradle
drwxr-xr-x. 3 root    root   20 May 16 13:34 gradle
-rwxr-xr-x. 1 root    root 4971 May 16 13:33 gradlew
drwxr-xr-x. 4 root    root   28 May 16 13:34 src
```

Mit `exit` bzw. `ctrl`+`d` kann wieder aus dem Pod bzw. der Shell ausgeloggt werden.


## Aufgabe 2: Befehle ausführen im Container

Einzelne Befehle innerhalb des Containers können über `oc exec` ausgeführt werden:

```bash
oc exec [POD] env
```

Zum Beispiel:

```bash
$ oc exec example-spring-boot-4-8mbwe env
PATH=/opt/app-root/src/bin:/opt/app-root/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=example-spring-boot-4-8mbwe
KUBERNETES_SERVICE_PORT_DNS_TCP=53
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_PORT_443_TCP_ADDR=172.30.0.1
KUBERNETES_PORT_53_UDP_PROTO=udp
KUBERNETES_PORT_53_TCP=tcp://172.30.0.1:53
...
```


## Logfiles betrachten

Die Logfiles zu einem Pod können sowohl in der Web Console als auch auch im CLI angezeigt werden:

```bash
oc logs [POD]
```

Der Parameter `-f` bewirkt dasselbe Verhalten wie `tail -f`, also "follow".

Befindet sich ein Pod im Status __CrashLoopBackOff__ bedeutet dies, dass er auch nach wiederholtem Neustarten nicht erfolgreich gestartet werden konnte.
Die Logfiles können auch wenn der Pod nicht läuft mit dem folgenden Befehl angezeigt werden:

```bash
oc logs -p [POD]
```

Der Parameter `-p` steht dabei für "previous", bezieht sich also auf einen Pod derselben DeploymentConfig, der zuvor noch lief, nun aber nicht mehr.
Entsprechend funktioniert dieser Befehl nur, wenn es tatsächlich einen Pod zuvor gab.

Mit OpenShift wird ein EFK-Stack (Elasticsearch, Fluentd, Kibana) mitgeliefert, der sämtliche Logfiles sammelt, rotiert und aggregiert.
Kibana erlaubt es Logs zu durchsuchen, zu filtern und grafisch aufzubereiten.

Kibana ist über den Link "View Archive" in der Web Console bei den Logs des Pods erreichbar.
Melden Sie sich in Kibana an, schauen Sie sich um und versuchen Sie, eine Suche für bestimmte Logs zu definieren.

<details><summary><b>Beispiel</b>: mysql Container Logs ohne Error-Meldungen</summary>kubernetes.container_name:"mysql" AND -message:"error"</details><br/>

Weitere Informationen und ein optionales Lab finden Sie [hier](../additional-labs/logging_efk_stack.md).


## Metriken

Die OpenShift Platform stellt auch ein Grundset an Metriken zur Verfügung, welche einerseits in der Web Console integriert sind und andererseits dazu genutzt werden können, Pods automatisch zu skalieren.

Sie können mit Hilfe eines direkten Logins auf einen Pod nun den Ressourcenverbrauch dieses Pods beeinflussen und die Auswirkungen dazu in der Web Console beobachten.


## Aufgabe 3: Port Forwarding

OpenShift erlaubt es, beliebige Ports von der Entwicklungs-Workstation auf einen Pod weiterzuleiten.
Dies ist z.B. nützlich, um auf Administrationskonsolen, Datenbanken, usw. zuzugreifen, die nicht gegen das Internet exponiert werden und auch sonst nicht erreichbar sind.
Die Portweiterleitungen werden über dieselbe HTTPS-Verbindung getunnelt, die der OpenShift Client (oc) auch sonst benutzt.
Dies erlaubt es auch dann auf Pods zu verbinden, wenn sich restriktive Firewalls und/oder Proxies zwischen Workstation und OpenShift befinden.

Übung: Auf die Spring Boot Metrics aus [Lab 4](04_deploy_dockerimage.md) zugreifen.

```bash
oc get pod --namespace="[USERNAME]-dockerimage"
oc port-forward [POD] 9000:9000 --namespace="[USERNAME]-dockerimage"
```

Nicht vergessen den Pod Namen an die eigene Installation anzupassen.
Falls installiert kann dafür Autocompletion verwendet werden.

Die Metrics können nun unter folgender URL abgerufen werden: [http://localhost:9000/metrics/](http://localhost:9000/metrics/).

Die Metrics werden Ihnen als JSON angezeigt.
Mit demselben Konzept können Sie nun bspw. mit Ihrem lokalen SQL Client auf eine Datenbank verbinden.

In der [Dokumentation](https://docs.openshift.com/container-platform/4.3/nodes/containers/nodes-containers-port-forwarding.html) sind weiterführende Informationen zu Port Forwarding zu finden.

__Note__:
Der `oc port-forward`-Prozess wird solange weiterlaufen, bis er vom User abgebrochen wird.
Sobald das Port-Forwarding also nicht mehr benötigt wird, kann er mit ctrl+c gestoppt werden.

---

__Ende Lab 8__

<p width="100px" align="right"><a href="09_database.md">Datenbank deployen und anbinden →</a></p>

[← zurück zur Übersicht](../README.md)
