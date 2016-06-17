# Lab 5: Unseren Service mittels Route online verfügbar machen

In diesem Lab werden wir die Applikation aus [Lab 4](04_deploy_dockerimage.md) über **http** vom Internet her erreichbar machen.

## Routen

Der `oc new-app` Befehl aus dem vorherigen [Lab](04_deploy_dockerimage.md) erstellt keine Route. Somit ist unser Service von *aussen* her gar nicht erreichbar. Will man einen Service verfügbar machen, muss dafür eine Route eingerichtet werden. Der OpenShift Router erkennt aufgrund des Host Headers auf welchen Service ein Request geleitet werden muss.

Aktuell werden folgende Protokolle unterstützt:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- WebSockets
- TLS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

## Aufgabe: LAB5.1

Vergewissern Sie sich, dass Sie sich im Projekt `[USER]-dockerimage` befinden. **Tipp:** `oc project [USER]-dockerimage`

Erstellen Sie für den Service `example-spring-boot` eine Route und machen Sie ihn darüber öffentlich verfügbar.

**Tipp:** Mittels `oc get routes` können Sie sich die Routen eines Projekts anzeigen lassen.

```
$ oc get routes
```

Aktuell gibt es noch keine Route. Jetzt brauchen wir den Servicenamen:

```
$ oc get services
NAME                  CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
example-spring-boot   172.30.124.20   <none>        8080/TCP   11m
```

Und nun wollen wir diesen Service veröffentlichen / exposen:

```
$ oc expose service example-spring-boot
```

Per default wird eine http Route erstellt.

Mittels `oc get routes` können wir überprüfen, ob die Route angelegt wurde.

```
$ oc get routes
NAME                  HOST/PORT                                        PATH      SERVICE                        TERMINATION   LABELS
example-spring-boot   example-spring-boot-techlab.app.appuio.ch             example-spring-boot:8080-tcp                 app=example-spring-boot
```

Die Applikation ist nun vom Internet her über den angegebenen Hostnamen erreichbar, Sie können also nun auf die Applikation zugreifen.

**Tipp:** Wird kein Hostname angegeben wird der Standardname verwendet: *servicename-project.osecluster*

In der Overview der Web Console ist diese Route mit dem Hostnamen jetzt auch sichtbar.


---

**Ende Lab 5**

[<< zurück zur Übersicht] (../README.md)

