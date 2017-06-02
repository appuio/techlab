# Lab 6: Pod Scaling, Readiness Probe und Self Healing

In diesem Lab zeigen wir auf, wie man Applikationen in OpenShift skaliert. Des Weiteren zeigen wir, wie OpenShift dafür sorgt, dass jeweils die Anzahl erwarteter Pods gestartet wird und wie eine Applikation der Plattform zurückmelden kann, dass sie bereit für Requests ist.

## Example Applikation hochskalieren

Dafür erstellen wir ein neues Projekt

```
$ oc new-project [USER]-scale
```

und fügen dem Projekt eine Applikation hinzu

```
$ oc new-app appuio/example-php-docker-helloworld --name=appuio-php-docker
```

und stellen den Service zur Verfügung (expose)

```
$ oc expose service appuio-php-docker
```

Wenn wir unsere Example Applikation skalieren wollen, müssen wir unserem ReplicationController (rc) mitteilen, dass wir bspw. stets 3 Replicas des Images am Laufen haben wollen.

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

## Aufgabe: LAB6.1 skalieren unserer Beispiel Applikation
Nun skalieren wir unsere Example Applikation auf 3 Replicas:

```
$ oc scale --replicas=3 rc appuio-php-docker-1
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

Skalieren von Pods innerhalb eines Services ist sehr schnell, da OpenShift einfach eine neue Instanz des Docker Images als Container startet.

**Tipp:** OpenShift V3 unterstützt auch Autoscaling, die Dokumentation dazu ist unter dem folgenden Link zu finden: https://docs.openshift.com/container-platform/3.4/dev_guide/pod_autoscaling.html

## Aufgabe: LAB6.2 skalierte App in der Web Console

Schauen Sie sich die skalierte Applikation auch in der Web Console an.

## Unterbruchsfreies Skalieren überprüfen

Mit dem folgenden Befehl können Sie nun überprüfen, ob Ihr Service verfügbar ist, während Sie hoch und runter skalieren.
Ersetzen Sie dafür `[route]` mit Ihrer definierten Route:

**Tipp:** oc get route

```
while true; do sleep 1; curl -s http://[route]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

oder in PowerShell (Achtung: erst ab PowerShell-Version 3.0!):

```
while(1) {
	Start-Sleep -s 1
	Invoke-RestMethod http://[route]/pod/
	Get-Date -Uformat "+ TIME: %H:%M:%S,%3N"
}
```

und skalieren Sie von **3** Replicas auf **1**.
Der Output zeigt jeweils den Pod an, der den Request verarbeitete:

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
Die Requests werden an die unterschiedlichen Pods geleitet, sobald man runterskaliert auf einen Pod, gibt dann nur noch einer Antwort

Was passiert nun, wenn wir nun während dem der While Befehl oben läuft, ein neues Deployment starten:

```
$ oc rollout latest appuio-php-docker
```
Währen einer kurzen Zeit gibt die öffentliche Route keine Antwort
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

In unserem Beispiel verwenden wir einen sehr leichtgewichtigen Pod. Das Verhalten ist ausgeprägter, wenn der Container länger braucht bis er Requests abarbeiten kann. Bspw. Java Applikation von LAB 4: **Startup: 30 Sekunden**

```
Pod: example-spring-boot-2-73aln TIME: 16:48:25,251
Pod: example-spring-boot-2-73aln TIME: 16:48:26,305
Pod: example-spring-boot-2-73aln TIME: 16:48:27,400
Pod: example-spring-boot-2-73aln TIME: 16:48:28,463
Pod: example-spring-boot-2-73aln TIME: 16:48:29,507
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:33,562
<html><body><h1>503 Service Unavailable</h1>
No server is available to handle this request.
</body></html>
 TIME: 16:48:34,601
 ...
Pod: example-spring-boot-3-tjdkj TIME: 16:49:20,114
Pod: example-spring-boot-3-tjdkj TIME: 16:49:21,181
Pod: example-spring-boot-3-tjdkj TIME: 16:49:22,231

```

Es kann dann sogar sein, dass der Service gar nicht mehr online ist und der Routing Layer ein **503 Error** zurück gibt.

Im Folgenden Kapitel wird beschrieben, wie Sie Ihre Services konfigurieren können, dass unterbruchsfreie Deployments möglich werden.


## Unterbruchsfreies Deployment mittels Readiness Probe und Rolling Update

Die Update Strategie [Rolling](https://docs.openshift.com/container-platform/3.4/dev_guide/deployments/deployment_strategies.html#rolling-strategy) ermöglicht unterbruchsfreie Deployments. Damit wird die neue Version der Applikation gestartet, sobald die Applikation bereit ist, werden Request auf den neuen Pod geleitet und die alte Version undeployed.

Zusätzlich kann mittels [Container Health Checks](https://docs.openshift.com/container-platform/3.4/dev_guide/application_health.html) die deployte Applikation der Plattform detailliertes Feedback über ihr aktuelles Befinden geben.

Grundsätzlich gibt es zwei Checks, die implementiert werden können:

- Liveness Probe, sagt aus, ob ein laufender Container immer noch sauber läuft.
- Readiness Probe, gibt Feedback darüber, ob eine Applikation bereit ist, um Requests zu empfangen. Ist v.a. im Rolling Update relevant.

Diese beiden Checks können als HTTP Check, Container Execution Check (Shell Script im Container) oder als TCP Socket Check implementiert werden.

In unserem Beispiel soll die Applikation der Plattform sagen, ob sie bereit für Requests ist. Dafür verwenden wir die Readiness Probe. Unsere Beispielapplikation gibt auf der folgenden URL auf Port 9000 (Management-Port der Spring Applikation) ein Status Code 200 zurück, sobald die Applikation bereit ist.
```
http://[route]/health/
```

## Aufgabe: LAB6.3

In der Deployment Config (dc) definieren im Abschnitt der Rolling Update Strategie, dass bei einem Update die App immer verfügbar sein soll: `maxUnavailable: 0%`

Dies kann in der Deployment Config (dc) konfiguriert werden:

**YAML:**
```
...
spec:
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 1
      intervalSeconds: 1
      timeoutSeconds: 600
      maxUnavailable: 0%
      maxSurge: 25%
    resources: {  }
...
```

Die Deployment Config kann via Web Console (Applications → Deployments → example-php-docker-helloworld, edit) oder direkt über `oc` editiert werden.
```
$ oc edit dc appuio-php-docker
```

Oder im JSON-Format editieren:
```
$ oc edit dc appuio-php-docker -o json
```
**json**
```
"strategy": {
    "type": "Rolling",
    "rollingParams": {
          "updatePeriodSeconds": 1,
          "intervalSeconds": 1,
          "timeoutSeconds": 600,
          "maxUnavailable": "0%",
          "maxSurge": "25%"
    },
    "resources": {}
}

```

Die Readiness Probe muss in der Deployment Config (dc) hinzugefügt werden, und zwar unter:

spec --> template --> spec --> containers unter halb von `resources: {  }`

**YAML:**

```
...
          resources: {  }
          readinessProbe:
            httpGet:
              path: /health/
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 10
            timeoutSeconds: 1
...
```

**json:**
```
...
                        "resources": {},
                        "readinessProbe": {
                            "httpGet": {
                                "path": "/health/",
                                "port": 8080,
                                "scheme": "HTTP"
                            },
                            "initialDelaySeconds": 10,
                            "timeoutSeconds": 1
                        },
...
```

Passen Sie das entsprechend analog oben an.

Die Konfiguration unter Container muss dann wie folgt aussehen:
**YAML:**
```
      containers:
        -
          name: example-php-docker-helloworld
          image: 'appuio/example-php-docker-helloworld@sha256:6a19d4a1d868163a402709c02af548c80635797f77f25c0c391b9ce8cf9a56cf'
          ports:
            -
              containerPort: 8080
              protocol: TCP
          resources: {  }
          readinessProbe:
            httpGet:
              path: /health/
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 10
            timeoutSeconds: 1
          terminationMessagePath: /dev/termination-log
          imagePullPolicy: IfNotPresent
```

**json:**
```
                "containers": [
                    {
                        "name": "appuio-php-docker",
                        "image": "appuio/example-php-docker-helloworld@sha256:9e927f9d6b453f6c58292cbe79f08f5e3db06ac8f0420e22bfd50c750898c455",
                        "ports": [
                            {
                                "containerPort": 8080,
                                "protocol": "TCP"
                            }
                        ],
                        "resources": {},
                        "readinessProbe": {
                            "httpGet": {
                                "path": "/health/",
                                "port": 8080,
                                "scheme": "HTTP"
                            },
                            "initialDelaySeconds": 10,
                            "timeoutSeconds": 1
                        },
                        "terminationMessagePath": "/dev/termination-log",
                        "imagePullPolicy": "Always"
                    }
                ],
```


Verifizieren Sie während eines Deployment der Applikation, ob nun auch ein Update der Applikation unterbruchsfrei verläuft:

Einmal pro Sekunde ein Request:
```
while true; do sleep 1; curl -s http://[route]/pod/; date "+ TIME: %H:%M:%S,%3N"; done
```

Starten des Deployments:
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
