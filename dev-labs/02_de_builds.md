# Builds

Es gibt drei verschiedene Arten von Builds:

1. Source-To-Image (s2i)
2. Binary Builds
3. Container aka. Docker Builds

Werfen wir einen Blick auf die verschiedenen Arten von Builds

## Source-To-Image

Einfachster Einstieg von einer Codebasis (z. B. Ruby, Python, PHP) in eine ausgeführte Anwendung, die alle Abhängigkeiten enthält.

Es erstellt alle erforderlichen Build- und Deployment-Konfigurationen.

Erstellen Sie zunächst ein Projekt mit dem Namen `s2i-[USER]`.

<details><summary>Befehl zum Erstellen eines Projekts</summary>oc new-project s2i-[USER]</details><br/>

Unser Beispiel basiert auf einer sehr einfachen PHP-Anwendung, welche auf APPUiO GitHub gehostet wird.
Erstellen Sie eine Applikation mit dem Namen `s2i` aus diesem Repository: <https://github.com/appuio/example-php-sti-helloworld.git>

Hinweis zur Befehlshilfe:

```bash
oc new-app -h
```

<details><summary>Befehl zum Erstellen einer App</summary>oc new-app https://github.com/appuio/example-php-sti-helloworld.git --name=s2i</details><br/>

Die `new-app` Funkionalität erkennt das Git Repo als PHP Projekt und erstellt eine s2i Applikation.

Überprüfen Sie den Status Ihres Projekts.

```bash
oc status
```

Erkunden Sie die verschiedenen Ressourcen, die mit dem `new-app` Befehl erstellt wurden.

Um etwas im Browser anzuzeigen, erstellen Sie eine Route für den Zugriff auf die Anwendung:

```bash
oc create route edge --insecure-policy=Allow --service=s2i
```

Die URL, welche nun auf unsere ruby applikation zeigt, erhalten wir indem wir die route beschreiben (`oc describe`). Sie finden die URL auch in der Web Console. Sehen sie sich die applikation auch dort an.

## Binary build

In diesem Beispiel wird beschrieben, wie Sie ein Webarchiv (war) in Wildfly mithilfe des OpenShift-Clients (oc) im binary Modus deployen.
Das Beispiel ist vom APPUiO-Blog inspiriert: <http://docs.appuio.ch/de/latest/app/wildflybinarydeployment.html>

### Erstellen Sie ein neues Projekt

```bash
oc new-project binary-build-[USER]
```

### Erstellen Sie die Deployment Verzeichnisstruktur

Bereiten Sie einen temporären Ordner vor und erstellen Sie darin die Deployment Verzeichnisstruktur.

Mindestens ein War-File kann im Deployment Ordner abgelegt werden. In diesem Beispiel wird eine vorhandene War-Datei aus einem Git-Repository heruntergeladen.

```bash
mkdir tmp-bin
cd tmp-bin
mkdir deployments
wget -O deployments/ROOT.war 'https://github.com/appuio/hello-world-war/blob/master/repo/ch/appuio/hello-world-war/1.0.0/hello-world-war-1.0.0.war?raw=true'
```

### Erstellen Sie einen neuen Build mit dem Wildfly Container Image

Das Flag *binary=true* zeigt an, dass dieser Build seine Daten direkt als Input erhält, anstatt via URL (Git Repo).

```bash
oc new-build --docker-image=openshift/wildfly-160-centos7 --binary=true --name=hello-world -l app=hello-world
```

Befehl mit Ausgabe:

```bash
$ oc new-build --docker-image=openshift/wildfly-160-centos7 --binary=true --name=hello-world -l app=hello-world
--> Found Docker image 5b42148 (6 weeks old) from Docker Hub for "openshift/wildfly-160-centos7"

    WildFly 16.0.0.Final
    --------------------
    Platform for building and running JEE applications on WildFly 16.0.0.Final

    Tags: builder, wildfly, wildfly16

    * An image stream will be created as "wildfly-160-centos7:latest" that will track the source image
    * A source build using binary input will be created
      * The resulting image will be pushed to image stream "hello-world:latest"
      * A binary build was created, use 'start-build --from-dir' to trigger a new build

--> Creating resources with label app=hello-world ...
    imagestream "wildfly-160-centos7" created
    imagestream "hello-world" created
    buildconfig "hello-world" created
--> Success
```

Siehe die Befehlsausgabe für die erstellten Ressourcen.

Überprüfen Sie die erstellten Ressourcen mit dem oc-Tool und in der Web Console. Finden Sie den erstellten Build in der Web Console?

## Build starten

Um einen Build auszulösen, geben Sie den folgenden Befehl ein. In einem kontinuierlichen Deployment-Prozess kann dieser Befehl wiederholt werden, wenn eine neue Binärdatei oder eine neue Konfiguration verfügbar ist.

Die Kernfunktion des Binary-Builds besteht darin, die Dateien für den Build aus dem lokalen Verzeichnis bereitzustellen.
Diese Dateien werden in den Build-Container geladen, der in OpenShift ausgeführt wird.

```bash
oc start-build hello-world --from-dir=. --follow
```

Der Parameter _--from-dir=._ teilt dem oc-Tool mit, welches Verzeichnis hochgeladen werden soll.

Das _--follow_-Flag zeigt das Build-Protokoll auf der Konsole an und wartet, bis der Build abgeschlossen ist.

### Eine neue Applikation erstellen

Erstellen Sie eine neue App basierend auf dem Container-Image, das mit dem Binary-Build erstellt wurde.

```bash
oc new-app hello-world -l app=hello-world
```

Siehe die Befehlsausgabe für die erstellten Ressourcen.

Überprüfen Sie die erstellten Ressourcen mit dem oc-Tool und in der Web Console.
Versuchen Sie herauszufinden, ob Wildfly gestartet ist.

### Applikations-Service als Route zur Verfügung stellen

```bash
oc create route edge --service=hello-world
```

Klicken Sie in der Web Console auf die Route, um die Ausgabe der `hello-world`-Anwendung anzuzeigen.

## Container Build

Wir können auch beliebige Container basierend auf Dockerfiles erstellen.

Erstellen Sie zunächst ein Projekt mit dem Namen `docker-build-[USER]`

```bash
oc new-project binary-build-[USER]
```

Befehl zum Erstellen eines Docker-Builds:

Stellen Sie sicher, dass Sie das techlab repo geklont haben und sich auf dem richtigen branch im Stammverzeichnis befinden.

```bash
oc new-build --strategy=docker --binary=true --name=httpd -l app=httpd centos/httpd-24-centos7
oc start-build httpd --from-dir=dev-labs/data/02_httpd --follow
```

Verfolgen Sie, wie der Build abläuft und ob das Image in Ihrer Registry vorhanden sein wird.

Erstellen Sie eine Applikation mit diesem Image und machen Sie es verfügbar:

```bash
oc new-app httpd -l app=httpd
oc create route edge --insecure-policy=Allow --service=httpd
```

Klicken Sie in der Web Console auf die Route, um die Website Ihrer Anwendung anzuzeigen.

Versuchen Sie, ein Easter-Egg unter der URL `/easter-egg.txt` hinzuzufügen. Wie würden Sie vorgehen?
Untersuchen Sie "dev-labs/data/02_httpd" auf einen Hinweis.

<details>
    <summary>Lösung</summary>
    Fügen Sie im Dockerfile einen COPY-Befehl hinzu, um die Datei easter-egg.txt nach /var/www/html/ zu kopieren :<br/>
    ...<br/>
    COPY ./easter-egg.txt /var/www/html/<br/>
    ...<br/>
    Nach der Anpassung muss ein neuer Build gestartet werden.
</details>
