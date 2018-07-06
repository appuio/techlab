# Lab 7: Troubleshooting, was ist im Pod?

In diesem Lab wird aufgezeigt, wie man im Fehlerfall und Troubleshooting vorgehen kann und welche Tools einem dabei zur Verfügung stehen.

## In Container einloggen

Wir verwenden dafür wieder das Projekt aus [Lab 4](04_deploy_dockerimage.md) `[USER]-dockerimage`. **Tipp:** `oc project [USER]-dockerimage`

Laufende Container werden als unveränderbare Infrastruktur behandelt und sollen generell nicht modifiziert werden. Dennoch gibt es Usecases, bei denen man sich in die Container einloggen muss. Zum Beispiel für Debugging und Analysen.

## Aufgabe: LAB7.1

Mit OpenShift können Remote Shells in die Pods geöffnet werden ohne dass man darin vorgängig SSH installieren müsste. Dafür steht einem der Befehl `oc rsh` zur Verfügung.

Wählen Sie mittels `oc get pods` einen Pod aus und führen Sie den folgenden Befehl aus:
```
$ oc rsh [POD]
```

Sie können nun über diese Shell Analysen im Container ausführen:

```
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

## Aufgabe: LAB7.2

Einzelne Befehle innerhalb des Containers können über `oc exec` ausgeführt werden:

```
$ oc exec [POD] env
```


```
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

## Logfiles anschauen

Die Logfiles zu einem Pod können sowohl in der Web Console als auch auch im CLI angezeigt werden.

```
$ oc logs [POD]
```
Der Parameter `-f` bewirkt analoges Verhalten wie `tail -f`

Befindet sich ein Pod im Status **CrashLoopBackOff** bedeutet dies, dass er auch nach wiederholtem Restarten nicht erfolgreich gestartet werden konnte. Die Logfiles können auch wenn der Pod nicht läuft mit dem folgenden Befehl angezeigt werden.

 ```
$ oc logs -p [POD]
```

Mit OpenShift wird ein EFK (Elasticsearch, Fluentd, Kibana) Stack mitgeliefert, der sämtliche Logfiles sammelt, rotiert und aggregiert. Kibana erlaubt es Logs zu durchsuchen, zu filtern und grafisch aufzubereiten. Weitere Informationen und ein optionales LAB finden sie [hier](../additional-labs/logging_efk_stack.md).


## Aufgabe: LAB7.3 Port Forwarding

OpenShift 3 erlaubt es, beliebige Ports von der Entwicklungs-Workstation auf einen Pod weiterzuleiten. Dies ist z.B. nützlich, um auf Administrationskonsolen, Datenbanken, usw. zuzugreifen, die nicht gegen das Internet exponiert werden und auch sonst nicht erreichbar sind. Im Gegensatz zu OpenShift 2 werden die Portweiterleitungen über dieselbe HTTPS-Verbindung getunnelt, die der OpenShift Client (oc) auch sonst benutzt. Dies erlaubt es auch dann auf OpenShift 3 Platformen zuzugreifen, wenn sich restriktive Firewalls und/oder Proxies zwischen Workstation und OpenShift befinden.

Übung: Auf die Spring Boot Metrics aus [Lab 4](04_deploy_dockerimage.md) zugreifen.

```
oc get po --namespace="[USER]-dockerimage"
oc port-forward example-spring-boot-1-xj1df 9000:9000 --namespace="[USER]-dockerimage"
```

Nicht vergessen den Pod Namen an die eigene Installation anzupassen. Falls installiert kann dafür Autocompletion verwendet werden.

Die Metrics können nun unter folgendem Link abgerufen werden: [http://localhost:9000/metrics/](http://localhost:9000/metrics/) Die Metrics werden Ihnen als Json angezeigt. Mit dem selben Konzept können Sie nun beispielsweise mit Ihrem localen SQL Client auf eine Datenbank verbinden.

Unter folgendem Link sind weiterführende Informationen zu Port Forwarding zu finden: https://docs.openshift.com/container-platform/3.5/dev_guide/port_forwarding.html

---

**Ende Lab 7**

<p width="100px" align="right"><a href="08_database.md">Datenbank deployen und anbinden →</a></p>

[← zurück zur Übersicht](../README.md)
