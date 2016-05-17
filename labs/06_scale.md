# Lab 6: Pods skalieren, ReadynessProbe und Self Healing

In diesem Lab zeigen wir auf wie man Applikationen in OpenShift skaliert. Des Weiteren zeigen wir wie OpenShift dafür sorgt, dass jeweils die Anzahl erwarteter Pods gestartet werden und wie eine Applikation der Plattform zurückmelden kann, dass sie bereit für Requests ist.

## Example Applikation hochskalieren

Wenn wir unsere Example Applikation skalieren wollen müssen wir somit unserem ReplicationController mitteilen, dass wir bspw. stets 3 Replicas des Images lauffend haben wollen.

Schauen wir uns mal den ReplicationController (rc) an

```
$ oc get rc

CONTROLLER                CONTAINER(S)            IMAGE(S)                                                                                                                SELECTOR                                                                                              REPLICAS   AGE
example-spring-boot-1     example-spring-boot     appuio/example-spring-boot@sha256:7823c6bbfdbdf1edcc20e104b1161fc8d4f33ef6cbbe054d14bd01b6154f90b0                      app=example-spring-boot,deployment=example-spring-boot-1,deploymentconfig=example-spring-boot         1          4h
```

Für mehr Details:

```
$ oc get rc example-spring-boot-1 -o json
```

Der ReplicationController sagt uns, wieviele Pods wir erwarten(spec), und wieviele aktuell deployed sind (status).

## Aufgabe: LAB6.1
nun skalieren wir unsere Example Applikation auf 3 Replicas

```
$ oc scale --replicas=3 rc example-spring-boot-1
```

Überprüfen wir die anzahl Replicas auf dem ReplicationController

```
$ oc get rc

CONTROLLER                CONTAINER(S)            IMAGE(S)                                                                                                                SELECTOR                                                                                              REPLICAS   AGE
example-spring-boot-1     example-spring-boot     appuio/example-spring-boot@sha256:7823c6bbfdbdf1edcc20e104b1161fc8d4f33ef6cbbe054d14bd01b6154f90b0                      app=example-spring-boot,deployment=example-spring-boot-1,deploymentconfig=example-spring-boot         3          4h
```

und zeigen entsprechend die Pods an

```
$ oc get pods
NAME                            READY     STATUS      RESTARTS   AGE
example-spring-boot-3-dujl6     1/1       Running     0          3s
example-spring-boot-3-nwzku     1/1       Running     0          4h
example-spring-boot-3-zszkn     1/1       Running     0          10s

```

Zum Schluss schauen wir uns noch den Service an, der sollte jetzt alle drei Endpoints referenzieren.
```
$ oc describe service example-spring-boot
Name:                   example-spring-boot
Namespace:              techlab
Labels:                 app=example-spring-boot
Selector:               app=example-spring-boot,deploymentconfig=example-spring-boot
Type:                   ClusterIP
IP:                     172.30.96.92
Port:                   8080-tcp        8080/TCP
Endpoints:              10.255.1.154:8080,10.255.1.159:8080,10.255.2.155:8080
Session Affinity:       None
No events.

```

Skalieren von Pods innerhalb eines Services ist sehr schnell, da OpenShift einfach eine neue Instanz des Docker images startet.

**Tipp:** OpenShift V3 unterstützt auch autoscaling: https://docs.openshift.com/enterprise/3.1/dev_guide/pod_autoscaling.html

## Aufgabe: LAB6.2

Schauen Sie sich die skalierte Applikation auch in der Web Console an.

## Unterbruchsfreihes skalieren überprüfen

Mit dem folgenden Befehl können Sie nun überprüfen ob ihr Service während dem Sie hoch und runter skalieren verfügbar ist.
Ersetzen Sie dafür `[route]` mit ihrer definierten route 
**Tipp:** oc get route

```
while true; do sleep 2; curl -s http://[route]/pod;echo "";done
```

Und skalieren sie von 3 replicas auf 1.
Der Output zeigt jeweils den Pod an der den Request verarbeitet:

```
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
Pod: example-spring-boot-1-rtp39
Pod: example-spring-boot-1-qnsw4
```

## Unterbruchsfreihes Deployment mittels Readyness probe

Mittels [Container Health Checks](https://docs.openshift.com/enterprise/3.1/dev_guide/application_health.html) kann die Applikation der Plattform detailliertes Feedback über ihr aktuelles befinden geben. 

Grundsätzlich git es zwei Checks die implementiert werden können:

- Liveness Probe, sagt aus ob ein laufender Container immer noch ok läuft
- Readiness Probe, gibt Feedback darüber ob eine Applikation bereit ist um Requests zu empfangen, vorallem im Rolling Update relevant

Diese beiden Checks können als HTTP Check, Container Execution Check (shell script im Container) oder als TCP Socket Check implementiert werden.

In unserem Beispiel soll die Applikation der Plattform sagen ob sie bereit für Requests ist, dafür verwenden wir die Readiness Probe. Unsere Beispiel Applikation gibt auf der folgenden URL ein Status Code 200 zurück sobald die Applikation bereit ist.
```
http://[route]/health
```

## Aufgabe: LAB6.3

Die Readiness Probe muss in der Deployment Config hinzugefügt werden und zwar unter:

spec --> template --> spec --> containers

```
...
          readinessProbe:
            httpGet:
              path: /health
              port: 9000
              scheme: HTTP
            initialDelaySeconds: 15
            timeoutSeconds: 1
...
```

Die Konfiguration unter Container muss dann wie folgt aussehen:

```
      containers:
        -
          name: example-spring-boot
          image: 'appuio/example-spring-boot@sha256:6a19d4a1d868163a402709c02af548c80635797f77f25c0c391b9ce8cf9a56cf'
          ports:
            -
              containerPort: 8080
              protocol: TCP
          resources: {  }
          readinessProbe:
            httpGet:
              path: /health
              port: 9000
              scheme: HTTP
            initialDelaySeconds: 15
            timeoutSeconds: 1
          terminationMessagePath: /dev/termination-log
          imagePullPolicy: IfNotPresent
```

Die DeploymentConfig kann via WebConsole oder direkt über `oc` editiert werden.
```
$ oc edit dc example-spring-boot
```

Verifizieren Sie während einem Deployment der Applikation, ob nun auch ein update der Applikation unterbruchsfrei ist:

Starten des Deployments
```
$ oc deploy example-spring-boot --latest
```
Alle zwei Secunden ein Request
```
while true; do sleep 2; curl -s http://[route]/pod;echo "";done
``` 


## Self Healing

Über den Replication Controller haben wir nun der Plattform mitgeteilt, dass jeweils n Replicas laufen sollen. Was passiert nun, wenn wir einen pod löschen.

Suche Sie mittels `oc get pods` einen running Pod aus, den Sie killen können.
Löschen Sie den Pod mit folgendem Befehl:
``` 
oc delete pod example-spring-boot-4-4ryze
``` 

und schauen Sie mittels
``` 
oc get pods -w
``` 

Wie OpenShift dafür sorgt, dass wieder n Replicas des genannten Pods laufen.


---

**Ende Lab 6**

[<< zurück zur Übersicht] (../README.md)


