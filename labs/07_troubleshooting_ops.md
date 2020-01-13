# Lab 7: Troubleshooting, was ist im Pod?

In diesem Lab wird aufgezeigt, wie man im Fehlerfall und Troubleshooting vorgehen kann und welche Tools einem dabei zur Verfügung stehen.

## In Container einloggen

Wir verwenden dafür wieder das Projekt aus [Lab 4](04_deploy_dockerimage.md) `[USER]-dockerimage`.

<details><summary>Tipp</summary>oc project [USER]-dockerimage</details><br/>

Laufende Container werden als unveränderbare Infrastruktur behandelt und sollen generell nicht modifiziert werden. Dennoch gibt es Usecases, bei denen man sich in die Container einloggen muss. Zum Beispiel für Debugging und Analysen.

## Aufgabe: LAB7.1

Mit OpenShift können Remote Shells in die Pods geöffnet werden ohne dass man darin vorgängig SSH installieren müsste. Dafür steht einem der Befehl `oc rsh` zur Verfügung.

Wählen Sie einen Pod aus und öffnen Sie die Remote Shell.

<details><summary>Tipp</summary>oc get pods<br/>oc rsh [POD]</details><br/>

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

## Aufgabe: LAB7.2

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

Die Logfiles zu einem Pod können sowohl in der Web Console als auch auch im CLI angezeigt werden.

```bash
oc logs [POD]
```

Der Parameter `-f` bewirkt analoges Verhalten wie `tail -f`

Befindet sich ein Pod im Status **CrashLoopBackOff** bedeutet dies, dass er auch nach wiederholtem Neustarten nicht erfolgreich gestartet werden konnte. Die Logfiles können auch wenn der Pod nicht läuft mit dem folgenden Befehl angezeigt werden.

```bash
oc logs -p [POD]
```

Der Parameter `-p` steht dabei für "previous", bezieht sich also auf einen Pod, der zuvor noch lief, nun aber nicht mehr. Entsprechend funktioniert dieser Befehl nur, wenn es tatsächlich einen Pod zuvor gab.

Mit OpenShift wird ein EFK (Elasticsearch, Fluentd, Kibana) Stack mitgeliefert, der sämtliche Logfiles sammelt, rotiert und aggregiert. Kibana erlaubt es Logs zu durchsuchen, zu filtern und grafisch aufzubereiten.

Kibana ist über den Link "View Archive" in der Web Console bei den Logs des Pods erreichbar. Melde dich im Kibana an, schaue dich um und versuche eine Suche für bestimmte Logs zu definieren.

<details><summary>Beispiel: mysql Container Logs ohne error Meldung</summary>kubernetes.container_name:"mysql" AND -message:"error"</details><br/>

Weitere Informationen und ein optionales LAB finden Sie [hier](../additional-labs/logging_efk_stack.md).

## Metriken

Die OpenShift Platform integriert auch ein Grundset an Metriken, welche einerseits im Web Console integriert werden und anderseits auch dazu genutzt werden, um Pods automatisch horizontal zu skalieren.

Sie können mit Hilfe eines direkten Logins auf einen Pod nun den Ressourcenverbrauch dieses Pods beeinflussen und die Auswirkungen dazu im Web Console beobachten.

## Aufgabe: LAB7.3 Port Forwarding

OpenShift erlaubt es, beliebige Ports von der Entwicklungs-Workstation auf einen Pod weiterzuleiten. Dies ist z.B. nützlich, um auf Administrationskonsolen, Datenbanken, usw. zuzugreifen, die nicht gegen das Internet exponiert werden und auch sonst nicht erreichbar sind. Im Gegensatz zu OpenShift 2 werden die Portweiterleitungen über dieselbe HTTPS-Verbindung getunnelt, die der OpenShift Client (oc) auch sonst benutzt. Dies erlaubt es auch dann auf OpenShift Plattformen zuzugreifen, wenn sich restriktive Firewalls und/oder Proxies zwischen Workstation und OpenShift befinden.

Übung: Auf die Spring Boot Metrics aus [Lab 4](04_deploy_dockerimage.md) zugreifen.

```bash
oc get pod --namespace="[USER]-dockerimage"
oc port-forward example-spring-boot-1-xj1df 9000:9000 --namespace="[USER]-dockerimage"
```

Nicht vergessen den Pod Namen an die eigene Installation anzupassen. Falls installiert kann dafür Autocompletion verwendet werden.

Die Metrics können nun unter folgender URL abgerufen werden: [http://localhost:9000/metrics/](http://localhost:9000/metrics/).

Die Metrics werden Ihnen als JSON angezeigt. Mit demselben Konzept können Sie nun bspw. mit Ihrem lokalen SQL Client auf eine Datenbank verbinden.

Unter folgendem Link sind weiterführende Informationen zu Port Forwarding zu finden: https://docs.openshift.com/container-platform/3.11/dev_guide/port_forwarding.html

**Note:** Der `oc port-forward`-Prozess wird solange weiterlaufen, bis er vom User abgebrochen wird. Sobald das Port-Forwarding also nicht mehr benötigt wird, kann er mit ctrl+c gestoppt werden.

---

**Ende Lab 7**

<p width="100px" align="right"><a href="08_database.md">Datenbank deployen und anbinden →</a></p>

[← zurück zur Übersicht](../README.md)
