# Lab 13: Eigene Templates erstellen

Im Unterschied zu [Lab 11](11_template.md) schreiben wir hier unsere eigenen Templates bevor wir damit Applikationen erstellen.

## Hilfreiche `oc`-Befehle

Auflisten aller Befehle:

```bash
oc help
```

Übersicht (fast) aller Ressourcen:

```bash
oc get all
```

Infos zu einer Ressource:

```bash
oc get <RESOURCE_TYPE> <RESOURCE_NAME>
oc describe <RESOURCE_TYPE> <RESOURCE_NAME>
```

## Generierung

Über `oc new-app` oder "\+Add" in der Web Console werden die Ressourcen automatisch angelegt.
In der Web Console kann die Erstellung einfach konfiguriert werden.

Für den produktiven Einsatz reicht das meistens nicht aus.
Da braucht es mehr Kontrolle über die Konfiguration.
Eigene Templates sind hierfür die Lösung.
Sie müssen jedoch nicht von Hand geschrieben sondern können als Vorlage generiert werden.

### Generierung vor Erstellung

Mit `oc new-app` parst OpenShift die gegebenen Images, Templates, Source Code Repositories usw. und erstellt die Definition der verschiedenen Ressourcen.
Mit der Option `-o` erhält man die Definition, ohne dass die Ressourcen angelegt werden.

So sieht die Definition vom hello-world Image aus:

```bash
oc new-app hello-world -o json
```

Spannend ist auch zu beobachten, was OpenShift aus einem eigenen Projekt macht.
Hierfür kann ein Git Repository oder ein lokaler Pfad des Rechners angeben werden.

Beispiel-Befehl, wenn man sich im Root-Verzeichnis des Projekts befindet:

```bash
oc new-app . -o json
```

Wenn verschiedene ImageStreams in Frage kommen oder keiner gefunden wurde, muss er spezifiziert werden:

```bash
oc new-app . --image-stream=wildfly:latest -o json
```

`oc new-app` erstellt immer eine Liste von Ressourcen.
Bei Bedarf kann eine solche mit [jq](https://stedolan.github.io/jq/) in ein Template konvertiert werden:

```bash
oc new-app . --image-stream=wildfly:latest -o json | \
  jq '{ kind: "Template", apiVersion: .apiVersion, metadata: {name: "mytemplate" }, objects: .items }'
```

### Generierung nach Erstellung

Bestehende Ressourcen werden mit `oc get -o json` bzw `oc get -o yaml` exportiert.

```bash
oc get route my-route -o json
```

Welche Ressourcen braucht es?

Für ein vollständiges Template sind folgende Ressourcen notwendig:

- ImageStreams
- BuildConfigurations
- DeploymentConfigurations
- PersistentVolumeClaims
- Routes
- Services

Beispiel-Befehl um einen Export der wichtigsten Ressourcen als Template zu generieren:

```bash
oc get is,bc,pvc,dc,route,service -o json > my-template.json
```

Attribute mit Wert `null` sowie die Annotation `openshift.io/generated-by` dürfen aus dem Template entfernt werden.

### Vorhandene Templates exportieren

Es können auch bestehende Templates der Plattform abgeholt werden um eigene Templates zu erstellen.

Verfügbare Templates sind im Projekt `openshift` hinterlegt.
Diese können wie folgt aufgelistet werden:

```bash
oc get templates -n openshift
```

So erhalten wir eine Kopie vom eap70-mysql-persistent-s2i Template:

```bash
oc get template eap72-mysql-persistent-s2i -o json -n openshift > eap72-mysql-persistent-s2i.json
```

## Parameter

Damit die Applikationen für die eigenen Bedürfnisse angepasst werden können, gibt es Parameter.
Generierte oder exportierte Templates sollten fixe Werte wie Hostnamen oder Passwörter durch Parameter ersetzen.

### Parameter von Templates anzeigen

Mit `oc process --parameters` werden die Parameter eines Templates angezeigt. Hier wollen wir sehen, welche Paramter im CakePHP MySQL Template definiert sind:

```bash
oc process --parameters cakephp-mysql-example -n openshift
NAME                           DESCRIPTION                                                                GENERATOR VALUE
NAME                           The name assigned to all of the frontend objects defined in this template.           cakephp-mysql-example
NAMESPACE                      The OpenShift Namespace where the ImageStream resides.                               openshift
MEMORY_LIMIT                   Maximum amount of memory the CakePHP container can use.                              512Mi
MEMORY_MYSQL_LIMIT             Maximum amount of memory the MySQL container can use.                                512Mi
...
```

### Parameter von Templates mit Werten ersetzen

Für die Erzeugung der Applikationen können gewünschte Parameter mit Werten ersetzt werden.
Dazu verwenden wir `oc process`:

```bash
oc process -f eap70-mysql-persistent-s2i.json \
  -v PARAM1=value1,PARAM2=value2 > processed-template.json
```

So werden Parameter vom Template mit den gegebenen Werten ersetzt und in eine neue Datei geschrieben. Diese Datei wird eine Liste von Resources/Items sein, welche mit `oc create` erstellt werden können:

```bash
oc create -f processed-template.json
```

Dies kann auch in einem Schritt erledigt werden:

```bash
oc process -f eap70-mysql-persistent-s2i.json \
  -v PARAM1=value1,PARAM2=value2 \
  | oc create -f -
```

## Templates schreiben

OpenShift Dokumentation: <https://docs.openshift.com/container-platform/4.3/openshift_images/using-templates.html>

Applikationen sollten so gebaut werden, dass sich pro Umgebung nur ein paar Konfigurationen unterscheiden.
Diese Werte werden im Template als Parameter definiert.
Somit ist der erste Schritt nach dem Generieren einer Template-Definition das Definieren von Parametern.
Das Template wird mit Variablen erweitert, welche dann mit den Parameterwerten ersetzt werden.
So wird bspw. die Variable `${DB_PASSWORD}` durch den Parameter mit Namen `DB_PASSWORD` ersetzt.

### Generierte Parameter

Oft werden Passwörter automatisch generiert, da der Wert nur im OpenShift Projekt verwendet wird.
Dies kann mit einer "generate"-Definition erreicht werden.

```
parameters:
  - name: DB_PASSWORD
    description: "DB connection password"
    generate: expression
    from: "[a-zA-Z0-9]{13}"
```

Diese Definition würde ein zufälliges, 13 Zeichen langes Passwort mit Klein- und Grossbuchstaben sowie Zahlen generieren.

Auch wenn ein Parameter mit "generate"-Definition konfiguriert ist, kann er bei der Erzeugung überschrieben werden.

### Template Merge

Wenn z.B eine App mit einer Datenbank zusammen verwendet wird, können die zwei Templates zusammengelegt werden.
Dabei ist es wichtig, die Template Parameter zu konsolidieren.
Dies sind meistens Werte für die Anbindung der Datenbank.
Dabei einfach in beiden Templates die gleiche Variable vom gemeinsamen Parameter verwenden.

## Anwenden vom Templates

Templates können mit `oc new-app -f <FILE>|<URL> -p <PARAM1>=<VALUE1>,<PARAM2>=<VALUE2>...` instanziert werden.
Wenn die Parameter des Templates bereits mit `oc process` gesetzt wurden, braucht es die Angabe der Parameter nicht mehr.

---

__Ende Lab 13__

[← zurück zur Übersicht](../README.md)
