# Lab 5: Unseren Service mittels Route online verfügbar machen

In diesem Lab werden wir die Applikation aus Lab 4 über http vom Internet her erreichbar machen.

## Routen

Der `oc new-app` Befehl aus dem vorherigen Lab, erstellt keine Route, somit ist unser Service von "aussen" her nicht erreichbar. Will man einen Service verfügbar machen, muss dafür eine Route eingerichtet werden. Der OpenShift Router erkennt aufgrund des Host Headers auf welchen Service ein Request geleitet werden muss.

Aktuell werden folgende Protokolle unterstützt:

- HTTP
- HTTPS ([SNI](https://en.wikipedia.org/wiki/Server_Name_Indication))
- WebSockets
- TLS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

## Aufgabe: LAB5.1

Vergewissern Sie sich, dass Sie sich im Projekt `[USER]-dockerimage` befinden. **Tipp:** `oc project [USER]-dockerimage`

Erstellen Sie für den Service `example-spring-boot` eine Route und machen Sie ihn darüber öffentlich verfügbar.

**Tipp:** Mittels `oc get routes` können sie sich die Routen eines Projektes anzeigen lassen.

```
$ oc get routes
```

aktuell gibt es noch keine Route. Jetzt brauchen wir den Service Namen:

```
$ oc get services
NAME                    CLUSTER_IP       EXTERNAL_IP   PORT(S)    SELECTOR                                                           AGE
example-spring-boot     172.30.96.92     <none>        8080/TCP   app=example-spring-boot,deploymentconfig=example-spring-boot       2h
```

Und nun wollen wir diesen Service veröffentlichen / exposen:

```
$ oc expose service example-spring-boot
```

Mittels `oc get routes` können wir überprüfen, ob die Route angelegt wurde.

```
$ oc get routes
NAME                    HOST/PORT                                      PATH      SERVICE                 LABELS                      INSECURE POLICY   TLS TERMINATION
example-spring-boot     example-spring-boot-techlab.example.com               example-spring-boot     app=example-spring-boot
```

Die Applikation ist nun vom Internet her über den angegebenen Hostnamen erreichbar, sie können nun auf die Applikation zugreifen.

**Tipp:** wird kein Hostname angegeben, wird der Standardname verwendet: servicename-project.osecluser



---

**Ende Lab 5**

[<< zurück zur Übersicht] (../README.md)






