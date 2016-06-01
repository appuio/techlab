# Lab 6: Pod Scaling, Readiness Probe und Self Healing

In diesem Lab zeigen wir auf, wie man Applikationen in OpenShift skaliert. Des Weiteren zeigen wir, wie OpenShift dafür sorgt, dass jeweils die Anzahl erwarteter Pods gestartet wird und wie eine Applikation der Plattform zurückmelden kann, dass sie bereit für Requests ist.

## Example Applikation hochskalieren

Dafür erstellen wir ein neues Projekt

```
$ oc new-project [USER]-scale
```

und fügen dem Projekt eine Applikation hinzu

```
$ oc new-app appuio/example-php-docker-helloworld
```

und exposen den Service

```
$ oc expose service example-php-docker-hello
```

Wenn wir unsere Example Applikation skalieren wollen, müssen wir unserem ReplicationController (rc) mitteilen, dass wir bspw. stets 3 Replicas des Images am Laufen haben wollen.

Schauen wir uns mal den ReplicationController (rc) etwas genauer an:

```
$ oc get rc

CONTROLLER                        CONTAINER(S)                    IMAGE(S)                                                                                                       SELECTOR                                                                                                                      REPLICAS   AGE
example-php-docker-helloworld-1   example-php-docker-helloworld   appuio/example-php-docker-helloworld@sha256:40bdf6a3aef52d7afa1716fb83457e0fa9fbf14a6f223eb219504b632d7661c9   app=example-php-docker-helloworld,deployment=example-php-docker-helloworld-1,deploymentconfig=example-php-docker-helloworld   1          5s
```

Für mehr Details:

```
$ oc get rc example-php-docker-helloworld-1 -o json
```

Der rc sagt uns, wieviele Pods wir erwarten (spec) und wieviele aktuell deployt sind (status).

## Aufgabe: LAB6.1 skalieren unserer Beispiel Applikation
Nun skalieren wir unsere Example Applikation auf 3 Replicas:

```
$ oc scale --replicas=3 rc example-php-docker-helloworld-1
```

Überprüfen wir die Anzahl Replicas auf dem ReplicationController:

```
$ oc get rc

CONTROLLER                        CONTAINER(S)                    IMAGE(S)                                                                                                       SELECTOR                                                                                                                      REPLICAS   AGE
example-php-docker-helloworld-1   example-php-docker-helloworld   appuio/example-php-docker-helloworld@sha256:40bdf6a3aef52d7afa1716fb83457e0fa9fbf14a6f223eb219504b632d7661c9   app=example-php-docker-helloworld,deployment=example-php-docker-helloworld-1,deploymentconfig=example-php-docker-helloworld   3          3m
```

und zeigen entsprechend die Pods an:

```
$ oc get pods
NAME                                    READY     STATUS    RESTARTS   AGE
example-php-docker-helloworld-1-375nb   1/1       Running   0          1m
example-php-docker-helloworld-1-vd3oj   1/1       Running   0          3m
example-php-docker-helloworld-1-zgdvl   1/1       Running   0          1m

```

Zum Schluss schauen wir uns den Service an. Der sollte jetzt alle drei Endpoints referenzieren:
```
$ oc describe svc example-php-docker-hello
Name:			example-php-docker-hello
Namespace:		techlab
Labels:			app=example-php-docker-helloworld
Selector:		app=example-php-docker-helloworld,deploymentconfig=example-php-docker-helloworld
Type:			ClusterIP
IP:			172.30.82.43
Port:			8080-tcp	8080/TCP
Endpoints:		10.255.0.41:8080,10.255.1.28:8080,10.255.1.29:8080
Session Affinity:	None
No events.

```

Skalieren von Pods innerhalb eines Services ist sehr schnell, da OpenShift einfach eine neue Instanz des Docker Images als Container startet.

**Tipp:** OpenShift V3 unterstützt auch Autoscaling, die Dokumentation dazu ist unter dem folgenden Link zu finden: https://docs.openshift.com/enterprise/3.1/dev_guide/pod_autoscaling.html

## Aufgabe: LAB6.2 skalierte App in der Web Console

Schauen Sie sich die skalierte Applikation auch in der Web Console an.

## Unterbruchsfreies Skalieren überprüfen

Mit dem folgenden Befehl können Sie nun überprüfen, ob Ihr Service verfügbar ist, währenddem Sie hoch und runter skalieren.
Ersetzen Sie dafür `[route]` mit Ihrer definierten Route:

**Tipp:** oc get route

```
while true; do sleep 2; curl -s http://[route]/pod/; echo ""; done
```

und skalieren Sie von 3 Replicas auf 1.
Der Output zeigt jeweils den Pod an, der den Request verarbeitete:

```
example-php-docker-helloworld-1-375nb
example-php-docker-helloworld-1-zgdvl
example-php-docker-helloworld-1-vd3oj
example-php-docker-helloworld-1-375nb
example-php-docker-helloworld-1-zgdvl
example-php-docker-helloworld-1-vd3oj
example-php-docker-helloworld-1-375nb
example-php-docker-helloworld-1-zgdvl
example-php-docker-helloworld-1-vd3oj
example-php-docker-helloworld-1-375nb
example-php-docker-helloworld-1-zgdvl
example-php-docker-helloworld-1-vd3oj
example-php-docker-helloworld-1-vd3oj
example-php-docker-helloworld-1-zgdvl
```

## Unterbruchsfreies Deployment mittels Readiness Probe und Rolling Update

Die Update Strategie [Rolling)](https://docs.openshift.com/enterprise/3.1/dev_guide/deployments.html#strategies) ermöglicht unterbruchsfreie Deployemnts. Damit wird die neue Version der Applikation gestartet, sobald die Applikation bereit ist, werden Request auf den neuen Pod geleitet und die alte Version undeployed.

Zusätzlich kann mittels [Container Health Checks](https://docs.openshift.com/enterprise/3.1/dev_guide/application_health.html) die deployete Applikation der Plattform detailliertes Feedback über ihr aktuelles Befinden geben.

Grundsätzlich gibt es zwei Checks, die implementiert werden können:

- Liveness Probe, sagt aus, ob ein laufender Container immer noch sauber läuft
- Readiness Probe, gibt Feedback darüber, ob eine Applikation bereit ist, um Requests zu empfangen. Ist v.a. im Rolling Update relevant.

Diese beiden Checks können als HTTP Check, Container Execution Check (Shell Script im Container) oder als TCP Socket Check implementiert werden.

In unserem Beispiel soll die Applikation der Plattform sagen, ob sie bereit für Requests ist. Dafür verwenden wir die Readiness Probe. Unsere Beispielapplikation gibt auf der folgenden URL auf Port 9000 (management Port der Spring Applikation) ein Status Code 200 zurück, sobald die Applikation bereit ist.
```
http://[route]/health
```

## Aufgabe: LAB6.3

In der Deployment Config (dc) definieren im Abschnitt der Rolling Update Strategie, dass bei einem Update die App immer verfügbar sein soll: `maxUnavailable: 0%`

Dies kann in der Deployment Config (dc) konfiguriert werden:

```
...
spec:
  strategy:
    type: Rolling
    rollingParams:
      updatePeriodSeconds: 2
      intervalSeconds: 2
      timeoutSeconds: 30
      maxUnavailable: 0%
      maxSurge: 25%
    resources: {  }
...
```

Die Deployment Config kann via WebConsole (Browse --> Deployments --> example-php-docker-helloworld, edit) oder direkt über `oc` editiert werden.
```
$ oc edit dc example-php-docker-helloworld
```

Oder im json Format editieren:
```
$ oc edit dc example-php-docker-helloworld -o json
```

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

spec --> template --> spec --> containers

```
...
          readinessProbe:
            httpGet:
              path: /health
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 15
            timeoutSeconds: 1
...
```
Passen Sie das entsprechend analog oben an.

Die Konfiguration unter Container muss dann wie folgt aussehen:

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
              path: /health
              port: 8080
              scheme: HTTP
            initialDelaySeconds: 15
            timeoutSeconds: 1
          terminationMessagePath: /dev/termination-log
          imagePullPolicy: IfNotPresent
```


Verifizieren Sie während eines Deployment der Applikation, ob nun auch ein Update der Applikation unterbruchsfrei verläuft:

Starten des Deployment:
```
$ oc deploy example-php-docker-helloworld --latest
```
Alle zwei Sekunden ein Request:
```
while true; do sleep 2; curl -s http://[route]/pod/; echo ""; done
``` 


## Self Healing

Über den Replication Controller haben wir nun der Plattform mitgeteilt, dass jeweils **n** Replicas laufen sollen. Was passiert nun, wenn wir einen Pod löschen?

Suchen Sie mittels `oc get pods` einen running Pod aus, den Sie *killen* können.
Löschen Sie den Pod mit folgendem Befehl
``` 
oc delete pod example-php-docker-helloworld-1-zgdvl
``` 

und schauen Sie mittels
``` 
oc get pods -w
``` 

wie OpenShift dafür sorgt, dass wieder **n** Replicas des genannten Pods laufen.


---

**Ende Lab 6**

[<< zurück zur Übersicht] (../README.md)

