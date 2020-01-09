# Builds

Es gibt drei verschiedene Arten von Builds:

1. Source-To-Image (s2i)
2. Binary Builds
3. Container aka. Docker Builds

Werfen wir einen Blick auf die verschiedenen Arten von Builds

## Source-To-Image

Einfachster Einstieg von einer Codebasis (z. B. Ruby, Python, PHP) in eine ausgeführte Anwendung, die alle Abhängigkeiten enthält.

Es erstellt alle erforderlichen Build- und Deployment-Konfigurationen.

Erstellen Sie zunächst ein Projekt mit dem Namen "[USER]-s2i"
<details><summary>Befehl zum Erstellen eines Projekts</summary>oc new-project [USER]-s2i</details><br/>

Unser Beispiel basiert auf einer sehr einfachen PHP-Anwendung, welche auf APPUiO GitHub gehostet wird.
Erstellen Sie eine Applikation mit dem Namen s2i aus diesem Repository: <https://github.com/appuio/example-php-sti-helloworld.git>

Hinweis zur Befehlshilfe:

    oc new-app -h

<details><summary>Befehl zum Erstellen einer App</summary>oc new-app https://github.com/appuio/example-php-sti-helloworld.git --name=s2i</details><br/>

Die `new-app` Funkionalität erkennt das Git Repo als PHP Projekt und erstellt eine s2i Applikation.

Überprüfen Sie den Status Ihres Projekts.
<details><summary>Projektstatusbefehl</summary>oc status</details><br/>

Erkunden Sie die verschiedenen Ressourcen, die mit dem `new-app` Befehl erstellt wurden.

Um etwas im Browser anzuzeigen, erstellen Sie eine Route für den Zugriff auf die Anwendung:

    oc create route edge --service=s2i

## Binary build

In diesem Beispiel wird beschrieben, wie Sie ein Webarchiv (war) in Wildfly mithilfe des OpenShift-Clients (oc) im binary Modus deployen.
Das Beispiel ist vom APPUiO-Blog inspiriert: <http://docs.appuio.ch/de/latest/app/wildflybinarydeployment.html>

### Erstellen Sie ein neues Projekt

Erstellen Sie ein Projekt mit dem Namen "[USER]-binary-build"
<details><summary>Befehl zum Erstellen eines Projekts</summary>oc new-project [USER]-binary-build</details><br/>

### Erstellen Sie die Deployment Ordnerstruktur

Bereiten Sie einen temporären Ordner vor und erstellen Sie die darin die Deployment Ordnerstruktur.

Mindestens ein War-File kann im Deployment Ordner abgelegt werden. In diesem Beispiel wird eine vorhandene War-Datei aus einem Git-Repository heruntergeladen:

```bash
mkdir tmp-bin
cd tmp-bin
mkdir deployments
wget -O deployments/ROOT.war 'https://github.com/appuio/hello-world-war/blob/master/repo/ch/appuio/hello-world-war/1.0.0/hello-world-war-1.0.0.war?raw=true'
```

### Erstellen Sie einen neuen Build mit dem Wildfly Docker Image

Erstellen Sie eine Build-Konfiguration für einen binary-Build mit folgenden Attributen:

* basis Docker Image: `openshift/wildfly-160-centos7`
* Name: `hello-world`
* Label: `app=hello-world`.
* Typ: `binary`

Das Flag *binary=true* zeigt an, dass dieser Build seine Daten als Input erhält anstatt dass er ihn über eine URL (Git Repo) holt.

Befehl:

```bash
oc new-build --docker-image=openshift/wildfly-160-centos7 --binary=true --name=hello-world -l app=hello-world
```

Befehl mit Ausgabe:

```bash
$ oc new-build --docker-image=openshift/wildfly-160-centos7 --binary=true --name=hello-world -l app=hello-world
--> Found Docker image 7ff222e (7 months old) from Docker Hub for "openshift/wildfly-160-centos7"

    WildFly 16.0.0.Final
    --------------------
    Platform for building and running JEE applications on WildFly 16.0.0.Final

    Tags: builder, wildfly, wildfly16

    * An image stream tag will be created as "wildfly-160-centos7:latest" that will track the source image
    * A source build using binary input will be created
      * The resulting image will be pushed to image stream tag "hello-world:latest"
      * A binary build was created, use 'start-build --from-dir' to trigger a new build

--> Creating resources with label app=hello-world ...
    imagestream.image.openshift.io "wildfly-160-centos7" created
    imagestream.image.openshift.io "hello-world" created
    buildconfig.build.openshift.io "hello-world" created
--> Success
```

Siehe die Befehlsausgabe für die erstellten Ressourcen.

Überprüfen Sie die erstellten Ressourcen mit dem oc-Tool und in der Webkonsole. Finden Sie den erstellten Build in der Webkonsole?

## Build Starten

Um einen Build auszulösen, geben Sie den folgenden Befehl ein. In einem kontinuierlichen Deployment-Prozess kann dieser Befehl wiederholt werden, wenn eine neue Binärdatei oder eine neue Konfiguration verfügbar ist.

Die Kernfunktion des Binary-Builds besteht darin, die Dateien für den Build aus dem lokalen Verzeichnis bereitzustellen.
Diese Dateien werden in den Build-Container geladen, der in OpenShift ausgeführt wird.

```bash
oc start-build hello-world --from-dir=. --follow
```

Der Parameter _--from-dir=._ teilt dem oc-Tool mit, welches Verzeichnis hochgeladen werden soll.

Das _--follow_-Flag zeigt das Build-Protokoll auf der Konsole an und wartet, bis der Build abgeschlossen ist.

### Eine neue Applikation Erstellen

Erstellen Sie eine neue App basierend auf dem Docker-Image, das mit dem Binary-Build erstellt wurde.

```bash
oc new-app hello-world -l app=hello-world
```

Siehe die Befehlsausgabe für die erstellten Ressourcen.

Überprüfen Sie die erstellten Ressourcen mit dem oc-Tool und in der Webkonsole.
Versuchen Sie herauszufinden, ob Wildfly gestartet ist.

### Applikations-Service als Route zur Verfügung stellen

```bash
oc create route edge --service=hello-world
```

Klicken Sie in der Webkonsole auf die Route, um die Ausgabe der `hello-world`-Anwendung anzuzeigen.

## Container Build

Wir können auch beliebige Container basierend auf Dockerfiles erstellen.

Erstellen Sie zunächst ein Projekt mit dem Namen "[USER]-docker-build"
<details><summary>Projektbefehl erstellen</summary>oc new-project [USER]-docker-build</details><br/>

Befehl zum Erstellen eines Docker-Builds:

```bash
oc new-build --strategy=docker --binary=true --name=web -l app=web centos/httpd-24-centos7
```

Klonen Sie das techlab Git-Repository, falls Sie es noch nicht getan haben.

```bash
git clone https://github.com/appuio/techlab.git
```

Wechseln Sie zum `workshop-3.11` Git Branch

```bash
git checkout workshop-3.11
```

Navigieren Sie zum Stammverzeichnis des Git-Repositorys (`cd techlab`).

Starten Sie den Build mit den Daten aus `workshop/data/02_httpd`:

```bash
oc start-build web --from-dir=workshop/data/02_httpd --follow
```

Verfolgen Sie, wie der Build abläuft und ob das Image in Ihrer Registrierung vorhanden sein wird.

Erstellen Sie eine Applikation mit diesem Image und machen Sie es verfügbar:

```bash
oc new-app web -l app=web
oc create route edge --service=web
```

Klicken Sie in der Webkonsole auf die Route, um die Website Ihrer Anwendung anzuzeigen.

Versuchen Sie, ein Easter-Egg unter der URL `/easter-egg.txt` hinzuzufügen. Nach der Anpassung muss ein neuer Build gestartet werden.
Untersuchen Sie "workshop/data/02_httpd" auf einen Hinweis.

<details>
    <summary>Lösung</summary>
    Fügen Sie im Dockerfile einen COPY-befehl hinzu, um die Datei easter-egg.txt nach /var/www/html/ zu kopieren :<br/>
    ...<br/>
    COPY ./easter-egg.txt /var/www/html/<br/>
    ...<br/>
    Starten Sie einen neuen Build.
</details>

Hat es funktioniert? -> <https://web-[USER]-docker-build.techlab-apps.openshift.ch/easter-egg.txt>
