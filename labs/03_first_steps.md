# Lab 3: Erste Schritte auf der Lab Plattform

In diesem Lab werden wir gemeinsam das erste Mal mit der Lab Plattform interagieren, dies sowohl über den oc Client wie auch über die Web Console

## CLI

**Note:** Versichern Sie sich, dass sie Lab 2 erfolgreich abgeschlossen haben

Mit dem folgenden Command können Sie sich auf der Lab OpenShift V3 Plattform anmelden:

```
$ oc login [URL]
```

**Note:** Die **URL**, Benutzernamen und Passwort für Ihren Account wird Ihnen entsprechend am Techlab durch den Instruktuor zur Verfügung gestellt.
**Note:** Es kann sein, dass Sie gefragt werden, ein Zertifikat einer *unknown authority* zu bestätigen, bestätigen Sie dies mit **y**
```
The server uses a certificate signed by an unknown authority.
You can bypass the certificate check, but any data you send to the server could be intercepted by others.
Use insecure connections? (y/n): 
```

Als Alternative können Sie dies dem oc command beim Aufruf mitgeben:
```
$ oc login [URL] --insecure-skip-tls-verify=true
```

Nach dem erfolgreichen Login wird ihnen das folgende angezeigt:
```
Login successful.
Welcome to OpenShift! See 'oc help' to get started.
```

Herzliche Gratulation, Sie sind nun mit der Lab Umgebung verbunden ;-)!!!

## Projekt erstellen

Ein Projekt in OpenShift ist das Top Leve Konzept um ihre Applikationen, Deployments, Builds, Container, ... zu organisieren. siehe [Lab1](01_quicktour.md)


## Aufgabe: LAB3.1
Erstellen Sie auf der Lab Plattform ein neues Projekt,

**Note**: verweden Sie für Ihren Projektnamen am besten Ihren github Namen, oder ihren Nachnamen

> Wie kann ein neues Projekt erstellt werden?

**Tipp** :information_source: 
```
$ oc help
```

## Web Console

Die OpenShift V3 Web Console erlaubt es den Benutzern gewisse Tasks direkt via Browser vorzunehmen. 

## Aufgabe: LAB3.2
1. Logen Sie sich nun via Web Console auf der Lab Plafform ein.

**Note:** Die **URL**, Benutzernamen und Passwort für Ihren Account wird Ihnen entsprechend am Techlab durch den Instruktuor zur Verfügung gestellt.

2. Gehen Sie nun in die Übersicht Ihres eben erstellten Projektes, aktuell ist das Projekt noch leer

3. Fügen Sie über *Add to Project* Ihre erste Applikation ihrem Projekt hinzu. Als Beispiel Projekt verwenden wir, ein APPUiO Example.
3.1 Wählen Sie das Basis Image PHP 5.6 aus
![php5.6](../images/lab_3_php5.6.png)
3.2 Geben Sie ihrem Beispiel einen sprechenden Namen und folgende URL als Repo URL
```
https://github.com/appuio/example-php-sti-helloworld.git
```
![php5.6](../images/lab_3_example1.png)

4. Der Build Ihrer Applikation wird gestartet, verfolgend Sie den Build und schauen Sie sich nach dem Deployment die Beispiel APP an.

![php5.6](../images/lab_3_example1-deployed.png)


Sie haben nun ihre erste Applikation mittels so genannetem **[Source to Image](https://docs.openshift.com/enterprise/3.1/architecture/core_concepts/builds_and_image_streams.html#source-build)** Build auf OpenShift deployed.


---

## Lösung: LAB3.1

```
$ oc new-project [NAME]
```
---

**Ende Lab 3**

[<< zurück zur Übersicht] (../README.md)