# Lab 6: Pod Scaling, Readiness Probe und Self Healing

In diesem Lab zeigen wir auf, wie man Applikationen in OpenShift skaliert.
Des Weiteren zeigen wir, wie OpenShift dafür sorgt, dass jeweils die Anzahl erwarteter Pods gestartet wird und wie eine Applikation der Plattform zurückmelden kann, dass sie bereit für Requests ist.

## Aufgabe: LAB6.1 Beispiel-Applikation hochskalieren

Dafür erstellen wir ein neues Projekt mit dem Namen `[USERNAME]-scale`.

<details><summary><b>Tipp</b></summary>oc new-project [USERNAME]-scale</details><br/>

Fügen Sie dem Projekt eine Applikation hinzu:

```bash
oc new-app appuio/example-php-docker-helloworld --name=appuio-php-docker
```

Und stellen den Service `appuio-php-docker` zur Verfügung (expose).

<details><summary><b>Tipp</b></summary>oc expose service appuio-php-docker</details><br/>

Wenn wir unsere Beispiel-Applikation skalieren wollen, müssen wir unserem ReplicationController (rc) mitteilen, dass wir bspw. stets 3 Replicas des Image am laufen haben wollen.

Schauen wir uns mal den ReplicationController (rc) etwas genauer an:

```bash
oc get rc
NAME                  DESIRED   CURRENT   AGE
appuio-php-docker-1   1         1         33s
```

Für mehr Details json- oder yaml-Output ausgeben lassen.

<details><summary><b>Tipp</b></summary>oc get rc appuio-php-docker-1 -o json<br/>oc get rc appuio-php-docker-1 -o yaml</details><br/>

Der rc sagt uns, wieviele Pods wir erwarten (spec) und wieviele aktuell deployt sind (status).

## Aufgabe: LAB6.2 Skalieren unserer Beispiel Applikation

Nun skalieren wir unsere Beispiel-Applikation auf 3 Replicas.
Der soeben betrachtete ReplicationController wird über die DeploymentConfig (dc) gesteuert, weshalb wir diese skalieren müssen, damit die gewünschte Anzahl Repclias vom rc übernommen wird:

```bash
oc scale --replicas=3 dc/appuio-php-docker
```

Überprüfen wir die Anzahl Replicas auf dem ReplicationController:

```bash
oc get rc
NAME                  DESIRED   CURRENT   AGE
appuio-php-docker-1   3         3         1m
```

und zeigen die Pods an:

```bash
oc get pods
NAME                        READY     STATUS    RESTARTS   AGE
appuio-php-docker-1-2uc89   1/1       Running   0          21s
appuio-php-docker-1-evcre   1/1       Running   0          21s
appuio-php-docker-1-tolpx   1/1       Running   0          2m
```

Zum Schluss schauen wir uns den Service an. Der sollte jetzt alle drei Endpoints referenzieren:

```bash
$ oc describe svc appuio-php-docker
Name:              appuio-php-docker
Namespace:         techlab-scale
Labels:            app=appuio-php-docker
Annotations:       openshift.io/generated-by=OpenShiftNewApp
Selector:          app=appuio-php-docker,deploymentconfig=appuio-php-docker
Type:              ClusterIP
IP:                172.30.152.213
Port:              8080-tcp  8080/TCP
TargetPort:        8080/TCP
Endpoints:         10.128.2.204:8080,10.129.1.56:8080,10.131.0.141:8080
Port:              8443-tcp  8443/TCP
TargetPort:        8443/TCP
Endpoints:         10.128.2.204:8443,10.129.1.56:8443,10.131.0.141:8443
Session Affinity:  None
Events:            <none>
```

Skalieren von Pods innerhalb eines Service ist sehr schnell, da OpenShift einfach eine neue Instanz des Container Images als Container startet.

__Tipp__:
OpenShift unterstützt auch [Autoscaling](https://docs.openshift.com/container-platform/4.3/nodes/pods/nodes-pods-autoscaling.html).

## Aufgabe: LAB6.3 Skalierte App in der Web Console

Schauen Sie sich die skalierte Applikation auch in der Web Console an.
Wie können Sie die Anzahl Replicas via Web Console steuern?

## Unterbruchsfreies Skalieren überprüfen

Mit dem folgenden Befehl können Sie nun überprüfen, ob Ihr Service verfügbar ist, während Sie hoch- und herunterskalieren.
Führen Sie folgenden Befehl in einem Terminal-Fenster aus und lassen ihn laufen, während Sie später skalieren.

Ersetzen Sie `[HOSTNAME]` mit dem Hostname Ihrer definierten Route:

__Tipp__:
Um den entsprechenden Hostname anzuzeigen, kann folgender Befehl verwendet werden:

`oc get route -o custom-columns=NAME:.metadata.name,HOSTNAME:.spec.host`

```bash
while true; do sleep 1; ( { curl -fs http://[HOSTNAME]/health/; date "+ TIME: %H:%M:%S,%3N" ;} & ) 2>/dev/null; done
```

oder in PowerShell (__Achtung__: erst ab PowerShell-Version 3.0!):

```bash
while(1) {
        Start-Sleep -s 1
        Invoke-RestMethod http://[HOSTNAME]/pod/
        Get-Date -Uformat "+ TIME: %H:%M:%S,%3N"
}
```

Der Output zeigt jeweils den Pod an, der den Request beantwortet hatte:

```bash
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

Skalieren Sie nun von __3__ Replicas auf __1__ währenddem die While-Schleife läuft.

Die Requests werden an die unterschiedlichen Pods aufgeteilt.
Sobald die Pods herunterskaliert wurden, gibt nur noch einer Antwort.

Was passiert nun, wenn wir während der noch immer laufenden While-Schleife ein neues Deployment starten?
Testen wir es:

```bash
oc rollout latest appuio-php-docker
```

Wie der Timestamp am Ende der Ausgabe zeigt, gibt während einer kurzen Zeit die öffentliche Route keine Antwort:

```bash
POD: appuio-php-docker-6-6xg2b TIME: 16:42:17,743
POD: appuio-php-docker-6-6xg2b TIME: 16:42:18,776
POD: appuio-php-docker-6-6xg2b TIME: 16:42:19,813
POD: appuio-php-docker-6-6xg2b TIME: 16:42:20,853
POD: appuio-php-docker-6-6xg2b TIME: 16:42:21,891
POD: appuio-php-docker-6-6xg2b TIME: 16:42:22,943
POD: appuio-php-docker-6-6xg2b TIME: 16:42:23,980
#
# keine Antwort
#
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

In unserem Beispiel verwenden wir einen sehr leichtgewichtigen Pod.
Der Ausfall wäre ausgeprägter, wenn der Container länger bräuchte, bis er Requests abarbeiten kann, bspw. die Java Applikation von LAB 4 (__Startup: 30 Sekunden__).

Es kann sogar passieren, dass der Service gar nicht mehr online ist und der Routing Layer als Response einen __503 Error__ zurück gibt.

Im folgenden Kapitel wird beschrieben, wie Sie Ihre Services konfigurieren können, damit unterbruchsfreie Deployments möglich werden.

## Unterbruchsfreies Deployment dank Health Checks und Rolling Update

Die "[Rolling Strategy](https://docs.openshift.com/container-platform/4.3/applications/deployments/deployment-strategies.html#deployments-rolling-strategy_deployment-strategies)" ermöglicht unterbruchsfreie Deployments.
Damit wird die neue Version der Applikation gestartet, sobald die Applikation bereit ist, werden Requests auf den neuen Pod geleitet und die alte Version entfernt.

Zusätzlich kann mittels [Container Health Checks](https://docs.openshift.com/container-platform/4.3/applications/application-health.html#application-health-configuring_application-health) die deployte Applikation der Plattform detailliertes Feedback über ihr aktuelles Befinden übermitteln.

Grundsätzlich gibt es zwei Arten von Health Checks, die implementiert werden können:

- Liveness Probe: Sagt aus, ob ein laufender Container immer noch sauber läuft
- Readiness Probe: Gibt Feedback darüber, ob eine Applikation bereit ist, Requests zu empfangen

Diese beiden Checks können als HTTP Check, Container Execution Check (Befehl oder z.B. Shell Script im Container) oder als TCP Socket Check implementiert werden.

In unserem Beispiel soll die Applikation der Plattform sagen, ob sie bereit für Requests ist.
Dafür verwenden wir die Readiness Probe. Unsere Beispielapplikation gibt unter dem Pfad `/health` einen Status Code 200 zurück, sobald die Applikation bereit ist.

```bash
http://[route]/health/
```

## Aufgabe: LAB6.4

Fügen Sie die Readiness Probe mit folgendem Befehl in der DeploymentConfig (dc) hinzu:

```bash
oc set probe dc/appuio-php-docker --readiness --get-url=http://:8080/health --initial-delay-seconds=10
```

Ein Blick in die DeploymentConfig zeigt, dass nun folgender Eintrag unter `.spec.template.spec.containers` eingefügt wurde:

```yaml
readinessProbe:
  failureThreshold: 3
  httpGet:
    path: /health
    port: 8080
    scheme: HTTP
  initialDelaySeconds: 10
  periodSeconds: 10
  successThreshold: 1
  timeoutSeconds: 1
```

Verifizieren Sie während eines Deployments der Applikation, dass nun auch ein Update der Applikation unterbruchsfrei verläuft, indem Sie die bereits verwendete While-Schlaufe während des folgenden Update-Befehls beobachten:

```bash
oc rollout latest appuio-php-docker
```

Jetzt sollten die Antworten ohne Unterbruch vom neuen Pod kommen.

## Self Healing

Über den Replication Controller haben wir nun der Plattform mitgeteilt, dass jeweils __n__ Replicas laufen sollen. Was passiert nun, wenn wir einen Pod löschen?

Suchen Sie mittels `oc get pods` einen Pod im Status "running" aus, den Sie _killen_ können.

Starten sie in einem eigenen Terminal den folgenden Befehl (anzeige der Änderungen an Pods)

```bash
oc get pods -w
```

Löschen Sie im anderen Terminal Pods mit folgendem Befehl:

```bash
oc delete pods -l deploymentconfig=appuio-php-docker
```

OpenShift sorgt dafür, dass wieder __n__ Replicas des genannten Pods laufen.

In der Web Console ist gut zu beobachten, wie der Pod zuerst hellblau ist, bis die Readiness Probe meldet, dass die Applikation nun bereit ist.

---

__Ende Lab 6__

<p width="100px" align="right"><a href="07_troubleshooting_ops.md">Troubleshooting →</a></p>

[← zurück zur Übersicht](../README.md)
