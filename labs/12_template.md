# Lab 12: Applikationstemplates

In diesem Lab zeigen wir auf, wie Templates ganze Infrastrukturen beschreiben und entsprechend mit einem Befehl instanziert werden können.


## Templates

Wie Sie in den vorangegangenen Labs gesehen haben, können einfach über die Eingabe unterschiedlicher Befehle Applikationen, Datenbanken, Services und deren Konfiguration erstellt und deployt werden.

Dies ist fehleranfällig und eignet sich schlecht zum Automatisieren.

OpenShift bietet dafür das Konzept von Templates, in welchen man eine Liste von Ressourcen beschreiben kann, die parametrisiert werden können.
Sie sind also quasi ein Rezept für eine ganze Infrastruktur (bspw. 3 ApplikationsContainer, eine Datenbank mit Persistent Storage).

__Note__:
Der Cluster Administrator kann globale Templates erstellen, welche allen Benutzern zur Verfügung stehen.

Alle vorhandenen Templates anzeigen:

```bash
oc get template -n openshift
```

Über die Web Console kann dies mit dem "Developer Catalog" gemacht werden. Stellen Sie dafür sicher, dass Sie sich in der Developer-Ansicht befinden, klicken Sie auf "\+Add" und filtern Sie nach Type Template.

Diese Templates können im JSON- oder YAML-Format sowohl im Git Repository neben Ihrem Source Code abgelegt werden als auch über eine URL aufgerufen oder gar lokal im Filesystem abgelegt sein.


## Aufgabe 1: Template instanzieren

Die einzelnen Schritte die wir in den vorherigen Labs manuell vorgenommen haben, können nun mittels Template in einem "Rutsch" durchgeführt werden.

Erstellen Sie ein neues Projekt mit Namen `[USERNAME]-template`.

<details><summary><b>Tipp</b></summary>oc new-project [USERNAME]-template</details><br/>

Template erstellen:

```bash
oc create -f https://raw.githubusercontent.com/appuio/example-spring-boot-helloworld/master/example-spring-boot-template.json
```

Template instanzieren:

```bash
oc new-app example-spring-boot

--> Deploying template example-spring-boot for "example-spring-boot"
     With parameters:
      APPLICATION_DOMAIN=
      MYSQL_DATABASE_NAME=appuio
      MYSQL_USER=appuio
      MYSQL_PASSWORD=appuio
      MYSQL_DATASOURCE=jdbc:mysql://mysql/appuio?autoReconnect=true
      MYSQL_DRIVER=com.mysql.jdbc.Driver
--> Creating resources ...
    imagestream "example-spring-boot" created
    deploymentconfig "example-spring-boot" created
    deploymentconfig "mysql" created
    route "example-spring-boot" created
    service "example-spring-boot" created
    service "mysql" created
--> Success
    Run 'oc status' to view your app.

```

Mittels folgendem Befehl wird das image importiert und das Deployment gestartet:

```bash
oc import-image example-spring-boot
```

Mit diesem Befehl wird die Datenbank ausgerollt:

```bash
oc rollout latest mysql
```

__Tipp__:
Sie könnten Templates auch direkt verarbeiten indem Sie ein Template mit `oc new-app -f template.json -p param=value` ausführen.

Als Abschluss dieses Labs können Sie sich noch das [Template](https://github.com/appuio/example-spring-boot-helloworld/blob/master/example-spring-boot-template.json) genauer anschauen.

__Note__:
Bestehende Ressourcen können als Template exportiert werden
Verwenden Sie dafür den Befehl `oc get -o json` bzw `oc get -o yaml`.

Bspw.:

```bash
oc get is,bc,dc,route,service -o json > example-spring-boot-template.json
```

Wichtig ist, dass die ImageStreams zuoberst im Template File definiert sind.
Ansonsten wird der erste Build nicht funktionieren.

---

__Ende Lab 12__

<p width="100px" align="right"><a href="13_template_creation.md">Eigene Templates erstellen →</a></p>

[← zurück zur Übersicht](../README.md)
