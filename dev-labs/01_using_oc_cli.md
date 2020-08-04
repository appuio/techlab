# OC CLI Verwendung

Melden Sie sich bei der Web Console an und machen Sie sich mit der Benutzeroberfläche vertraut.

Ein Projekt ist eine Gruppierung von Ressourcen (container and docker images, pods, services, routes, configuration, quotas, limits and more). Die für das Projekt berechtigten Benutzer können diese Ressourcen verwalten. Der Projektname muss innerhalb des OpenShift clusters eindeutig sein.
Erstellen Sie über die Web Console ein neues Projekt mit dem Namen:

    [USER]-webui

## Loggen Sie mit der CLI ein

Kopieren Sie den Login-Befehl von der Web Console (haben Sie diese Option gefunden? -> im Menü auf der rechten Seite)

    oc login https://techlab.openshift.ch:443 --token=XYZ
    oc whoami

Mit dem Token haben Sie eine angemeldete Sitzung und können sich über die CLI (auf der API) anmelden, ohne dort die Authentifizierung vorzunehmen.

Sobald Sie angemeldet sind, machen wir uns mit der CLI und ihren Befehlen vertraut.

## Hilfe bekommen

oc cli bietet eine Hilfeausgabe sowie eine ausführlichere Hilfe für jeden Befehl:

    oc help
    oc projects -h
    oc projects

## Erstellen Sie ein neues Projekt mit dem CLI

Erstellen Sie ein Projekt mit dem Namen "[USER]-cli"

Damit erhalten Sie Hilfe zur Projekt Erstellung

    oc new-project -h

<details><summary>Lösung</summary>oc new-project [USER]-cli</details><br/>

Wir wechseln automatisch zu unserem Projekt:

    oc project

Wir können unser Projekt überprüfen, indem wir es entweder beschreiben oder eine yaml (oder json) formatierte Ausgabe unseres erstellten Projekts erhalten.

    oc describe project [USER]-cli
    oc get project [USER]-webui -o yaml
    oc get project [USER]-webui -o json

## Hinzufügen von Benutzern zu einem Projekt

OpenShift kann mehrere Benutzer (auch mit unterschiedlichen Rollen) in einem Projekt haben. Dazu können wir dem Projekt einzelne Benutzer oder auch eine Gruppe von Benutzern hinzufügen.

Benutzer oder Gruppen können unterschiedliche Rollen innerhalb des gesamten Clusters oder lokal innerhalb eines Projekts haben.

Weitere Informationen zu Rollen finden Sie [hier](https://docs.openshift.com/container-platform/latest/authentication/using-rbac.html) und zu deren Verwaltung [hier](https://docs.openshift.com/container-platform/4.3/authentication/using-rbac.html#viewing-cluster-roles_using-rbac).

Um alle aktiven Rollen in Ihrem aktuellen Projekt anzuzeigen, können Sie folgendes eingeben:

    oc describe rolebinding.rbac

Für Ihr webui Projekt:

    oc describe rolebinding.rbac -n [USER]-webui

Wir können Rollen verwalten, indem wir Befehle für `oc adm policy` absetzen:

    oc adm policy -h

Für dieses Lab gibt es eine Gruppe namens `techlab`, in der alle Techlab-Benutzer enthalten sind.

Fügen wir diese Gruppe mit der Administrator Rolle zu unserem aktuellen Projekt hinzu, damit wir die Sachen in diesen Projekten gemeinsam entwickeln können.

    oc adm policy add-role-to-group -h
    oc adm policy add-role-to-group admin techlab -n [USER]-cli

Zu viele Rechte? Zumindest für unser webui Projekt, also lasst uns die Benutzer nur als Viewer hinzufügen:

    oc adm policy add-role-to-group view techlab -n [USER]-webui

Sie können auch die bisherigen Berechtigungen des `[USER]-cli` Projekts entfernen.

    oc adm policy remove-role-from-group admin techlab -n [USER]-cli

Wie viele andere haben uns zu ihren Projekten hinzugefügt? Schauen wir uns die aktuelle Liste der Projekte an:

    oc projects

Überprüfen Sie die Änderungen in der Web Console. Gehen Sie zu Ihren beiden Projekten und finden Sie die techlab Gruppe unter _Resources -> Membership_

## Überprüfen und Bearbeiten anderer Ressourcen

Alles in OpenShift (Kubernetes) wird als Ressource repräsentiert, die wir anzeigen und abhängig von unseren Berechtigungen bearbeiten können.

Sie können alle Ressourcen Ihres aktuellen Projekts abrufen, indem Sie folgendes eingeben:

    oc get all

Sie sehen nichts? Oder nur "No resources found."
Dies liegt daran, dass wir noch nichts deployed haben. Sie können eine infache Applikation deployen und den `oc get` Befahl wiederholen.

    oc new-app https://github.com/appuio/example-php-sti-helloworld.git

Sie können auch alle Ressourcen der Namespaces (Projekte) abrufen, auf die Sie Zugriff haben.

Nehmen Sie das Projekt `openshift-web-console`, das einige Ressourcen zum untersuchen enthält.
Klicken Sie auf Befehl, wenn Sie keine Lösung gefunden haben, wie Sie den Namespace zum Befehl hinzufügen können.

<details><summary>Befehl</summary>oc get all -n openshift-web-console</details><br/>

Wenn Sie eine interessante Ressource gefunden haben, die Sie untersuchen möchten, können Sie jede einzelne mit den Befehlen `describe/get` anschauen:

<details><summary>allgemeiner Befehl</summary>oc describe [RESOURCE_TYPE] [RESOURCE_NAME] -n openshift-web-console</details>
<details><summary>Befehl zum Überprüfen eines Service</summary>oc describe service webconsole -n openshift-web-console</details><br/>

Sie können die Ressourcen auch bearbeiten:

    oc edit [RESOURCE_TYPE] [RESOURCE_NAME]

Lassen Sie uns zum Beispiel unser webui Projekt bearbeiten.

<details><summary>Befehl</summary>oc edit project [USER]-webui</details><br/>

Dies war nur ein Beispiel. Verlassen Sie den Editor, indem Sie Folgendes eingeben: _ESC_ und _:_ und _q_

## Ressourcen löschen

Sie sind nicht glücklich darüber, wie Ihre aktuellen Projekte verlaufen sind und möchten von vorne beginnen?

    oc delete project [USER]-webui

Dadurch werden alle von diesem Projekt gebündelten Ressourcen gelöscht. Projekte sind eine einfache Möglichkeit, Dinge auszuprobieren, und wenn Sie fertig sind, können Sie sie problemlos bereinigen.

## Wie geht es meinen Ressourcen?

Sie können sich jederzeit einen Überblick über Ihre aktuellen Ressourcen verschaffen, indem Sie folgendes eingeben:

    oc status

Dies wird praktisch, sobald wir mehr Sachen deployen.
