# Lab 6: Pod Scaling, Readiness Probe und Self Healing

In diesem Lab zeigen wir auf, wie man Applikationen in OpenShift skaliert. Des Weiteren zeigen wir, wie OpenShift dafür sorgt, dass jeweils die Anzahl erwarteter Pods gestartet wird und wie eine Applikation der Plattform zurückmelden kann, dass sie bereit für Requests ist.


## Aufgabe: LAB6.1 Beispiel-Applikation hochskalieren

Dafür erstellen wir ein neues Projekt:

```
$ oc new-project [USER]-scale
```

Fügen dem Projekt eine Applikation hinzu:

```
$ oc new-app appuio/example-php-docker-helloworld --name=appuio-php-docker
```

Und stellen den Service zur Verfügung (expose):

```
$ oc expose service appuio-php-docker
```

Wenn wir unsere Beispiel-Applikation skalieren wollen, müssen wir unserem ReplicationController (rc) mitteilen, dass wir bspw. stets 3 Replicas des Image am laufen haben wollen.

Schauen wir uns mal den ReplicationController (rc) etwas genauer an:

```
$ oc get rc

NAME                  DESIRED   CURRENT   AGE
appuio-php-docker-1   1         1         33s
```

Für mehr Details:

```
$ oc get rc appuio-php-docker-1 -o json
```

Der rc sagt uns, wieviele Pods wir erwarten (spec) und wieviele aktuell deployt sind (status).


## Aufgabe: LAB6.2 Skalieren unserer Beispiel Applikation

Nun skalieren wir unsere Beispiel-Applikation auf 3 Replicas. Der soeben betrachtete ReplicationController wird über die DeploymentConfig (dc) gesteuert, weshalb wir diese skalieren müssen, damit die gewünschte Anzahl Repclias vom rc übernommen wird:

```
$ oc scale --replicas=3 dc appuio-php-docker
```

Überprüfen wir die Anzahl Replicas auf dem ReplicationController:

```
$ oc get rc

NAME                  DESIRED   CURRENT   AGE
appuio-php-docker-1   3         3         1m
```

und zeigen entsprechend die Pods an:

```
$ oc get pods
NAME                        READY     STATUS    RESTARTS   AGE
appuio-php-docker-1-2uc89   1/1       Running   0          21s
appuio-php-docker-1-evcre   1/1       Running   0          21s
appuio-php-docker-1-tolpx   1/1       Running   0          2m
```

Zum Schluss schauen wir uns den Service an. Der sollte jetzt alle drei Endpoints referenzieren:
```
$ oc describe svc appuio-php-docker
Name:			appuio-php-docker
Namespace:		techlab-scale
Labels:			app=appuio-php-docker
Selector:		app=appuio-php-docker,deploymentconfig=appuio-php-docker
Type:			ClusterIP
IP:				172.30.166.88
Port:			8080-tcp	8080/TCP
Endpoints:		10.1.3.23:8080,10.1.4.13:8080,10.1.5.15:8080
Session Affinity:	None
No events.
```

Skalieren von Pods innerhalb eines Service ist sehr schnell, da OpenShift einfach eine neue Instanz des Container Image als Container startet.

**Tipp:** OpenShift unterstützt auch Autoscaling, die Dokumentation dazu ist unter dem folgenden Link zu finden: https://docs.openshift.com/container-platform/3.11/dev_guide/pod_autoscaling.html


## Aufgabe: LAB6.3 Skalierte App in der Web Console

Schauen Sie sich die skalierte Applikation auch in der Web Console an. Wie können Sie die Anzahl Replicas via Web Console steuern?


## Unterbruchsfreies Skalieren überprüfen

Mit dem folgenden Befehl können Sie nun überprüfen, ob Ihr Service verfügbar ist, während Sie hoch- und herunterskalieren. Führen Sie folgenden Befehl in einem Terminal-Fenster aus und lassen ihn laufen, während Sie später skalieren.

Ersetzen Sie `[HOSTNAME]` mit dem Hostname Ihrer definierten Route:

**Tipp:** `oc get route -o custom-columns=NAME:.metadata.name,HOSTNAME:.spec.host`

```
while true; do sleep 1; ( { curl -fs http://appuio-php-docker-baffolter-scale.techlab-apps.openshift.ch/health/; date "+ TIME: %H:%M:%S,%3N" ;} & ) 2>/dev/null; done
```

oder in PowerShell (**Achtung**: erst ab PowerShell-Version 3.0!):

```
while(1) {
	Start-Sleep -s 1
	Invoke-RestMethod http://[HOSTNAME]/pod/
	Get-Date -Uformat "+ TIME: %H:%M:%S,%3N"
}
```

Der Output zeigt jeweils den Pod an, der den Request beantwortet hatte:

```
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:04,991
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:06,053
POD: appuio-php-docker-6-6xg2b TIME: 16:40:07,091
POD: appuio-php-docker-6-6xg2b TIME: 16:40:08,128
POD: appuio-php-docker-6-ctbrs TIME: 16:40:09,175
POD: appuio-php-docker-6-ctbrs TIME: 16:40:10,212
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:11,279
POD: appuio-php-docker-6-9w9t4 TIME: 16:40:12,332
POD: appuio-php-docker-6-6xg2b TIME: 16:40:13,369
POD: appuio-php-docker-6-6xg2b TIME: 16:40:14,407
POD: appuio-php-docker-6-6xg2b TIME: 16:40:15,441
POD: appuio-php-docker-6-6xg2b TIME: 16:40:16,493
POD: appuio-php-docker-6-6xg2b TIME: 16:40:17,543
POD: appuio-php-docker-6-6xg2b TIME: 16:40:18,591
```

Skalieren Sie nun von **3** Replicas auf **1**, währenddem die While-Schleife läuft.

Die Requests werden an die unterschiedlichen Pods aufgeteilt. Sobald die Pods herunterskaliert wurden, gibt nur noch einer Antwort.

Was passiert nun, wenn wir während der noch immer laufenden While-Schleife ein neues Deployment starten? Testen wir es:

```
$ oc rollout latest appuio-php-docker
```

Wie der Timestamp am Ende der Ausgabe zeigt, gibt während einer kurzen Zeit die öffentliche Route keine Antwort:

```
POD: appuio-php-docker-6-6xg2b TIME: 16:42:17,743
POD: appuio-php-docker-6-6xg2b TIME: 16:42:18,776
POD: appuio-php-docker-6-6xg2b TIME: 16:42:19,813
POD: appuio-php-docker-6-6xg2b TIME: 16:42:20,853
POD: appuio-php-docker-6-6xg2b TIME: 16:42:21,891
POD: appuio-php-docker-6-6xg2b TIME: 16:42:22,943
POD: appuio-php-docker-6-6xg2b TIME: 16:42:23,980
# keine Antwort
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:42,134
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:43,181
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:44,226
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:45,259
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:46,297
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:47,571
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:48,606
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:49,645
POD: appuio-php-docker-7-pxnr3 TIME: 16:42:50,684
```

In unserem Beispiel verwenden wir einen sehr leichtgewichtigen Pod. Der Ausfall wäre ausgeprägter, wenn der Container länger bräuchte, bis er Requests abarbeiten kann, bspw. die Java Applikation von LAB 4 (**Startup: 30 Sekunden**).

Es kann sogar passieren, dass der Service gar nicht mehr online ist und der Routing Layer als Response einen **503 Error** zurück gibt.

Im folgenden Kapitel wird beschrieben, wie Sie Ihre Services konfigurieren können, damit unterbruchsfreie Deployments möglich werden.


## Unterbruchsfreies Deployment dank Health Checks und Rolling Update

Die Update Strategy "[Rolling](https://docs.openshift.com/container-platform/3.11/dev_guide/deployments/deployment_strategies.html#rolling-strategy)" ermöglicht unterbruchsfreie Deployments, indem die neue Version der Applikation gestartet, die alte Version aber erst gestoppt wird, sobald die neue bereit ist.

Zusätzlich kann mittels [Health Checks](https://docs.openshift.com/container-platform/3.11/dev_guide/application_health.html) die deployte Applikation detailliertes Feedback an die Plattform über ihr aktuelles Befinden übermitteln.

Grundsätzlich gibt es zwei Arten von Health Checks, die implementiert werden können:

- Liveness Probe: Sagt aus, ob ein laufender Container immer noch sauber läuft
- Readiness Probe: Gibt Feedback darüber, ob eine Applikation bereit ist, Requests zu empfangen

Diese beiden Checks können als HTTP Check, Container Execution Check (Befehl oder z.B. Shell Script im Container) oder als TCP Socket Check implementiert werden.

In unserem Beispiel soll die Applikation der Plattform sagen, ob sie bereit für Requests ist. Dafür verwenden wir die Readiness Probe. Unsere Beispielapplikation gibt unter dem Pfad `/health` einen Status Code 200 zurück, sobald die Applikation bereit ist.


## Aufgabe: LAB6.4

Fügen Sie die Readiness Probe mit folgendem Befehl in der DeploymentConfig (dc) hinzu:

```
$ oc set probe dc/appuio-php-docker --readiness --get-url=http://:8080/health --initial-delay-seconds=10
```

Ein Blick in die DeploymentConfig zeigt, dass nun folgender Eintrag unter `.spec.template.spec.containers` eingefügt wurde:

```
        readinessProbe:
          failureThreshold: 3
          httpGet:
            path: /health
            port: 8080
            scheme: HTTP
          initialDelaySeconds: 10
          timeoutSeconds: 1
```

Verifizieren Sie während eines Deployments der Applikation, dass nun auch ein Update der Applikation unterbruchsfrei verläuft, indem Sie die bereits verwendete While-Schlaufe während des folgenden Update-Befehls beobachten:

```
$ oc rollout latest appuio-php-docker
```


## Self Healing

Über den Replication Controller haben wir nun der Plattform mitgeteilt, dass jeweils **n** Replicas laufen sollen. Was passiert nun, wenn wir einen Pod löschen?

Suchen Sie mittels `oc get pods` einen Pod im Status "running" aus, den Sie *killen* können.

Starten sie in einem eigenen Terminal den folgenden Befehl (anzeige der Änderungen an Pods)
```
oc get pods -w
```
Löschen Sie im anderen Terminal einen Pod mit folgendem Befehl
```
oc delete pod appuio-php-docker-3-788j5
```

OpenShift sorgt dafür, dass wieder **n** Replicas des genannten Pods laufen.


---

**Ende Lab 6**

<p width="100px" align="right"><a href="07_troubleshooting_ops.md">Troubleshooting, was ist im Pod? →</a></p>

[← zurück zur Übersicht](../README.md)
