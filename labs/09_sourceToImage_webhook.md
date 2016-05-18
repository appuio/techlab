# Lab 9: Code Changes durch Webhook triggern Rebuild auf OpenShift

In diesem Lab zeigen wir den Docker Build Workflow anhand eines Beispiels auf und Sie lernen, wie Sie mit einem Push in das Git Repository einen Build und ein Deployment der Applikation auf OpenShift starten.

## Aufgabe: LAB9.1: Vorbereitung Github Account und Fork

### Github Account

Damit Sie Änderungen am Source Code unserer Beispielapplikation vornehmen können, benötigen Sie einen eigenen GitHub Account. Richten Sie sich einen Account unter https://github.com/ ein, falls Sie nicht bereits über einen verfügen.

### Beispiel-Projekt forken

**Beispiel-Projekt:** https://github.com/appuio/example-php-sti-helloworld

Gehen Sie auf die [GitHub Projekt-Seite](https://github.com/appuio/example-php-sti-helloworld) und [forken](https://help.github.com/articles/fork-a-repo/) Sie das Projekt.

![Fork](../images/lab_9_fork_example.png)


Sie haben nun unter
```
https://github.com/[YourGitHubUser]/example-php-sti-helloworld
```

einen Fork des Example Projektes, den Sie so erweitern können wie sie wollen.

## Deployen des eigenen Forks

Erstellen Sie ein neues Projekt:
```
$ oc new-project [USER]-example3
```

Erstellen Sie für Ihren Fork eine neue App. **Note:** Ersetzen Sie `[YourGithubUser]` mit dem Namen Ihres GitHub Accounts:

```
$ oc new-app https://github.com/[YourGithubUser]/example-php-docker-helloworld.git --strategy=docker --name=appuio-php-docker-ex
```

Nun exponieren Sie den Service mit:
```
$ oc expose service appuio-php-docker-ex
```

## Aufgabe: LAB9.2: Webhook auf GitHub einrichten

Beim Erstellen der App wurden in der BuildConfig direkt Webhooks definiert. Diese können Sie über den folgenden Befehl anzeigen:
```
$ oc describe bc appuio-php-docker-ex

Name:			appuio-php-docker-ex
Created:		About a minute ago
Labels:			app=appuio-php-docker-ex
Annotations:		openshift.io/generated-by=OpenShiftNewApp
Latest Version:		1
Strategy:		Docker
Source Type:		Git
URL:			https://github.com/appuio/example-php-docker-helloworld.git
From Image:		ImageStreamTag openshift/php:5.6
Output to:		ImageStreamTag appuio-php-docker-ex:latest
Triggered by:		Config, ImageChange
Webhook GitHub:		https://example.com:8443/oapi/v1/namespaces/example3/buildconfigs/appuio-php-docker-ex/webhooks/_Nxh9v9jE8u6wEXfloBr/github
Webhook Generic:	https://example.com:8443/oapi/v1/namespaces/example3/buildconfigs/appuio-php-docker-ex/webhooks/fAyPWZ5vqlXQYu4HVfRB/generic

Build			Status		Duration		Creation Time
appuio-php-docker-ex-1 	running 	running for 59s 	2016-05-17 18:04:39 +0200 CEST

```

Den GitHub Webhook können Sie auch von der Web Console kopieren. Gehen Sie dafür via Browse --> Builds auf den entsprechenden Build und wählen Sie das Tab Configuration aus:

![Webhook](../images/lab_9_webhook_ose3.png)

Kopieren Sie die GitHub [Webhook](https://developer.github.com/webhooks/) URL und fügen Sie sie auf GitHub entsprechend ein.

Klicken Sie in Ihrem Projekt auf Settings:
![Github Webhook](../images/lab_09_webhook_github1.png)

Klicken Sie auf Webhooks & services:
![Github Webhook](../images/lab_09_webhook_github2.png)

Fügen Sie einen Webhook hinzu:
![Github Webhook](../images/lab_09_webhook_github3.png)

Fügen Sie die entsprechende GitHub Webhook URL aus Ihrem OpenShift Projekt ein und "disablen" Sie die SSL verification. Auf der Lab Plattform verfügen wir nur über self-signed Zertifikate.
![Github Webhook](../images/lab_09_webhook_github4.png)

Ab jetzt triggern alle Pushes auf Ihrem GitHub Repository einen Build und deployen anschliessend die Code-Änderungen direkt auf die OpenShift-Plattform.

## Aufgabe: LAB9.3: Code anpassen

Klonen Sie Ihr Git Repository und wechseln Sie in das Code Verzeichnis:
```
$ git clone https://github.com/[YourGithubUser]/example-php-docker-helloworld.git
$ cd example-php-docker-helloworld
```

Passen Sie das File bspw. auf Zeile 56 ./app/index.php an:
```
$ vim app/index.php
```

![Github Webhook](../images/lab_9_codechange1.png)

```
    <div class="container">

      <div class="starter-template">
        <h1>Hallo <?php echo 'OpenShift Techlab'?></h1>
        <p class="lead">APPUiO Example Dockerfile PHP</p>
      </div>

    </div>
```

Pushen Sie Ihren Change:
```
$ git add .
$ git commit -m "updated Hello"
$ git push
```

Als Alternative können Sie das File auch direkt auf GitHub editieren:
![Github Webhook](../images/lab_9_edit_on_github.png)

Sobald Sie die Änderungen gepushed haben, startet OpenShift einen Build des neuen Source Code
```
$ oc get builds
```

und deployed anschliessend die Änderung.

## Aufgabe: LAB9.4: Rollback

Mit OpenShift lassen sich unterschiedliche Software-Stände aktivieren und deaktivieren, indem einfach eine andere Version des Image gestartet wird.

Dafür werden die Befehle `oc rollback` und `oc deploy` verwendet.
 
Um ein Rollback auszuführen, brauchen Sie den Namen der DeploymentConfig:

```
$ oc get dc

NAME                  TRIGGERS                    LATEST
appuio-php-docker-ex   ConfigChange, ImageChange   2

```

Mit dem folgenden Befehl können Sie nun ein Rollback auf die Vorgänger-Version ausführen:

```
$ oc rollback appuio-php-docker-ex
#3 rolled back to appuio-php-docker-ex-1
Warning: the following images triggers were disabled: appuio-php-docker-ex
  You can re-enable them with: oc deploy appuio-php-docker-ex --enable-triggers -n phptest
```

Sobald das Deployment der alten Version erfolgt ist, können Sie über ihren Browser überprüfen, ob wieder die ursprüngliche Überschrift **Hello APPUiO** angezeigt wird.

**Tipp:** Die automatischen Deployments neuer Versionen ist nun für diese Applikation augeschaltet um ungewollte Änderungen nach dem Rollback zu verhindern. Um das automatische Deployment wieder einzuschalten führen Sie den folgenden Befehl aus:
 

```
$ oc deploy appuio-php-docker-ex --enable-triggers
```

---

**Ende Lab 9**

[<< zurück zur Übersicht] (../README.md)

