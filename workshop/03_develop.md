# Applikation Entwickeln

In diesen Labs werden wir Applikationen Entwickeln.

## Aufgaben

### Container Image deployen

Folgen Sie den Anweisungen im [Lab 4: Ein Container Image deployen](labs/04_deploy_dockerimage.md).

### Service mittels Route online verfügbar machen

In dieser Aufgabe werden wir die Applikation von vorher über **https** vom Internet her erreichbar machen.

Folgen Sie den Anweisungen im [Lab 5: Unseren Service mittels Route online verfügbar machen](labs/05_create_route.md).

### Pod Scaling, Readiness Probe und Self Healing

Folgen Sie den Anweisungen im [Lab 6: Pod Scaling, Readiness Probe und Self Healing](labs/06_scale.md).

### Datenbank anbinden

Folgen Sie den Anweisungen im [Lab 8: Datenbank anbinden](labs/08_database.md).

## Zusatzübung für Schnelle

Ziel ist es eine Java Spring Boot Applikation lokal zu Bauen und mittels Binary Build auf die Plattform zu bringen.

* Siehe dazu das Binary Build Beispiel des Labs [workshop/02-builds.md](workshop/02-builds.md) an.
* GitHub Repository mit dem Sourcecode: <https://github.com/appuio/example-spring-boot-helloworld>
* Docker Hub Repository mit Java Docker Image: <https://hub.docker.com/r/fabric8/java-centos-openjdk8-jdk/>

### Projekt erstellen

Neues Projekt mit dem Namen `userXY-spring-boot` erstellen.
<details><summary>Tipp</summary>oc new-project userXY-spring-boot</details><br/>

### Applikation Bauen

Zuerst das GitHub Repository klonen und danach das Spring Boot Jar bauen.
<details><summary>Git Klone Befehl</summary>git clone https://github.com/appuio/example-spring-boot-helloworld.git</details><br/>

Danach die Applikation bauen, es wird nur das JDK 1.8 benötigt.
<details>
    <summary>Applikation Bauen</summary>
    cd example-spring-boot-helloworld/<br/>
    ./gradlew build<br/>
</details><br/>

### Deployment Ordner Struktur

Für den Binary Build eine Ordner Struktur vorbreiten mit dem Jar vom Java Build.

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

### Applikation Testen

Im Browser oder mit curl das Funktionieren der Applikation überprüfen.
