# Lab 5: Unseren Service mittels Route online verfügbar machen

In diesem Lab werden wir die Applikation aus [Lab 4](04_deploy_dockerimage.md) über das HTTP-Protokoll vom Internet her erreichbar machen.

## Routen

Der `oc new-app` Befehl aus dem vorherigen [Lab](04_deploy_dockerimage.md) erstellt keine Route. Somit ist unser Service von *aussen* her gar nicht erreichbar.
Will man einen Service verfügbar machen, muss dafür eine Route eingerichtet werden. Der OpenShift Router erkennt aufgrund des Host Headers auf welchen Service ein Request geleitet werden muss.

Aktuell werden folgende Protokolle unterstützt:

* HTTP
* HTTPS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)
* WebSockets
* TLS mit [SNI](https://en.wikipedia.org/wiki/Server_Name_Indication)

## Aufgabe: LAB5.1

Vergewissern Sie sich, dass Sie sich im Projekt `[USER]-dockerimage` befinden.
<details><summary>Tipp</summary>[USER]-dockerimage</details><br/>

Erstellen Sie für den Service `example-spring-boot` eine Route und machen Sie ihn darüber öffentlich verfügbar.

**Tipp:** Mittels `oc get routes` können Sie sich die Routen eines Projekts anzeigen lassen.

```bash
$ oc get routes
No resources found.
```

Aktuell gibt es noch keine Route. Jetzt brauchen wir den Servicenamen:

```bash
$ oc get services
NAME                  TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
example-spring-boot   ClusterIP   172.30.141.7   <none>        8080/TCP,8778/TCP,9779/TCP   14m
```

Und nun wollen wir diesen Service veröffentlichen bzw exponieren:

```bash
oc expose service example-spring-boot
```

Per default wird eine unverschlüsselte http Route erstellt.
Die ist jedoch nicht sicher, darum erstellen wir noch eine https Route.

```bash
oc create route edge example-spring-boot-secure --service=example-spring-boot
```

Mittels `oc get routes` können wir überprüfen, ob die Routen angelegt wurden.

```bash
$ oc get routes
NAME                         HOST/PORT                                         PATH      SERVICES              PORT       TERMINATION   WILDCARD
example-spring-boot          example-spring-boot-techlab.mycluster.com                   example-spring-boot   8080-tcp                 None
example-spring-boot-secure   example-spring-boot-secure-techlab.mycluster.com            example-spring-boot   8080-tcp   edge          None
```

Die Applikation ist nun vom Internet her über den angegebenen Hostnamen erreichbar, Sie können also nun auf die Applikation zugreifen.

**Tipp:** Wird kein Hostname angegeben wird der Standardname verwendet: *servicename-project.osecluster*

In der Overview der Web Console ist diese Route mit dem Hostnamen jetzt auch sichtbar.

Öffnen Sie die Applikation im Browser und fügen ein paar "Say Hello" Einträge ein.

---

**Ende Lab 5**

<p width="100px" align="right"><a href="06_scale.md">Skalieren →</a></p>

[← zurück zur Übersicht](../README.md)
