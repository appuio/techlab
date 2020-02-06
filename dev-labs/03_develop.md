# Applikation entwickeln

In diesen Labs werden wir Applikationen entwickeln.

## Aufgaben

### Container Image deployen

Folgen Sie den Anweisungen im [Lab 4: Ein Container Image deployen](../labs/04_deploy_dockerimage.md).

### Service mittels Route online verfügbar machen

In dieser Aufgabe werden wir die Applikation von vorher über **https** vom Internet her erreichbar machen.

Folgen Sie den Anweisungen im [Lab 5: Unseren Service mittels Route online verfügbar machen](../labs/05_create_route.md).

### Pod Scaling, Readiness Probe und Self Healing

Folgen Sie den Anweisungen im [Lab 6: Pod Scaling, Readiness Probe und Self Healing](../labs/06_scale.md).

### Datenbank anbinden

Folgen Sie den Anweisungen im [Lab 8: Datenbank anbinden](../labs/08_database.md).

## Zusatzübung für Schnelle

Ziel ist es eine Java Spring Boot Applikation lokal zu bauen und mittels Binary Build auf die Plattform zu bringen.

- Siehe dazu das Binary Build Beispiel des Labs [dev-labs/02_builds.md](./02_builds.md).
- GitHub Repository mit dem Sourcecode: <https://github.com/appuio/example-spring-boot-helloworld>
- Docker Hub Repository mit Java Docker Image: <https://hub.docker.com/r/fabric8/java-centos-openjdk8-jdk/>

### Projekt erstellen

Neues Projekt mit dem Namen `[USER]-spring-boot` erstellen.

<details><summary>Tipp</summary>oc new-project [USER]-spring-boot</details><br/>

### Applikation bauen

Zuerst das GitHub Repository klonen oder als [Zip-Datei](https://github.com/appuio/example-spring-boot-helloworld/archive/master.zip) laden und danach das Spring Boot Jar bauen.

<details><summary>Git Clone Befehl</summary>git clone https://github.com/appuio/example-spring-boot-helloworld.git</details><br/>

Danach die Applikation bauen, es wird nur das JDK 1.8 benötigt.

<details>
    <summary>Applikation bauen</summary>
    cd example-spring-boot-helloworld/<br/>
    ./gradlew build<br/>
</details><br/>

<details>
    <summary>Applikation bauen (auf Windows)</summary>
    ins Verzeichnis <i>example-spring-boot-helloworld</i> wechseln<br/>
    gradlew.bat build<br/>
</details><br/>

### Deployment Verzeichnisstruktur

Für den Binary Build eine Verzeichnisstruktur vorbereiten mit dem Jar vom Java Build.

* Verzeichnis: `tmp-jar/deployments`
* Datei: build/libs/springboots2idemo-0.0.1-SNAPSHOT.jar

Befehle für Shell und PowerShell:

```bash
mkdir tmp-jar
cd tmp-jar
mkdir deployments
cp ../build/libs/springboots2idemo-0.0.1-SNAPSHOT.jar deployments/
```

#### Lokaler Test mit Docker

Dockerfile mit diesem Inhalt erstellen.

```Dockerfile
FROM fabric8/java-centos-openjdk8-jdk

COPY deployments/*.jar deployments/

EXPOSE 8080
```

Builden und starten.

```bash
docker build -t boot .
docker run -ti -p 8080:8080 boot
```

Applikation ist unter <http://localhost:8080> erreichbar.

### Binary Build mit Dockerfile

Dockerfile Build im OpenShift erstellen.

```bash
oc new-build -D $'FROM fabric8/java-centos-openjdk8-jdk\nCOPY deployments/*.jar deployments/\nEXPOSE 8080' --to spring-boot
```

Wie ist der Name des ImageSteam, in welchen das gebaute Image gepushed wird?

Binary Build starten mit dem Inhalt aus diesem Ordner.

<details><summary>Tipp</summary>oc start-build spring-boot --from-dir=. --follow</details><br/>

### Applikation erstellen

Applikation anhand des Image Stream erstellen mit dem Label `app=spring-boot`.

<details><summary>Tipp</summary>oc new-app spring-boot -l app=spring-boot</details><br/>

### Route erstellen

Den Service der Applikation als Route exposen.

<details><summary>Tipp</summary>oc create route edge --service=spring-boot --port=8080</details><br/>

Wieso müssen wir hier den Port angeben?

### Applikation testen

Im Browser oder mit curl das Funktionieren der Applikation überprüfen.

## Zusatzübung für ganz Schnelle

Folgen Sie den Anweisungen im [Lab 9: Code Changes durch Webhook triggern Rebuild auf OpenShift](../labs/09_dockerbuild_webhook.md).
