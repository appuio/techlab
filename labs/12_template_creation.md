# Lab 12: Eigene Templates erstellen

Im Unterschied zum [Lab 11](11_template.md) schreiben/definieren wir hier unsere eigenen Templates bevor wir damit Applikationen erstellen.

## Hilfreiche oc client Befehle
Auflisten aller Befehle:
```
$ oc help
```

Konzepte und Typen:
```
$ oc types
```

Übersicht aller Ressourcen:
```
$ oc get all
```

Infos zu einer Ressource:
```
$ oc get <RESOURCE_TYPE> <RESOURCE_NAME>
$ oc describe <RESOURCE_TYPE> <RESOURCE_NAME>
```

## Generierung
Über "oc new-app" oder "Add to project" in der Web Konsole werden die Ressourcen automatisch angelegt. In der Web Konsole kann die Erstellung einfach konfiguriert werden.

Für den produktiven Einsatz reicht das meistens nicht aus. Da braucht es mehr Kontrolle über die Konfiguration. Eigene Templates sind hierfür die Lösung. Sie müssen jedoch nicht von Hand geschrieben sondern können als Vorlage generiert werden.

### Generierung vor Erstellung
Mit **oc new-app** parst OpenShift die gegebenen Images, Templates, Source Code Repositories usw. und erstellt die Definition der verschiedenen Ressourcen. Mit der Option **-o** erhält man die Definition ohne dass die Ressourcen angelegt werden.

So sieht die Definition vom hello-world Image aus.
```
$ oc new-app hello-world -o json
```

Spannend ist auch zu beobachten, was OpenShift aus einem eigenen Projekt macht. Hierfür kann ein Git Repository oder ein lokaler Pfad des Rechners angeben werden.

Beispiel-Befehl, wenn man sich im Root-Verzeichnis des Projekts befindet:
```
$ oc new-app . -o json
```
Wenn verschiede ImageStreams in Frage kommen oder keiner gefunden wurde, muss er spezifiziert werden:
```
$ oc new-app . --image-stream=wildfly:latest -o json
```

`oc new-app` erstellt immer eine Liste von Ressourcen. Bei Bedarf kann eine solche mit [jq](https://stedolan.github.io/jq/) in ein Template konvertiert werden:
```
$ oc new-app . --image-stream=wildfly:latest -o json | \
  jq '{ kind: "Template", apiVersion: .apiVersion, metadata: {name: "mytemplate" }, objects: .items }'
```

### Generierung nach Erstellung
Bestehende Ressourcen werden mit **oc export** exportiert.
```
$ oc export route my-route
```

Welche Ressourcen braucht es?

Für ein vollständiges Template sind folgende Ressourcen notwendig:
* Image Streams
* Build Configurations
* Deployment Configurations
* Persistent Volume Claims
* Routes
* Services

Beispiel-Befehl um einen Export der wichtigsten Ressourcen als Template zu generieren:
```
$ oc export is,bc,pvc,dc,route,service --as-template=my-template -o json > my-template.json
```
Ohne die Option *--as-template* würde eine Liste von Items anstatt eines Templates mit Objects exportiert.

Momentan gibt es einen offenen [Issue](https://github.com/openshift/origin/issues/8327) welcher zur Folge hat, dass ImageStreams nach dem re-importieren nicht mehr korrekt funktionieren. Als Workaround kann das Attribut `.spec.dockerImageRepository`, falls vorhanden, mit dem Wert des Attributs `.tags[0].annotations["openshift.io/imported-from"]` ersetzt werden. Mit [jq](https://stedolan.github.io/jq/) kann dies gleich automatisch erledigt werden:

```
$ oc export is,bc,pvc,dc,route,service --as-template=my-template -o json |
  jq '(.objects[] | select(.kind == "ImageStream") | .spec) |= \
    (.dockerImageRepository = .tags[0].annotations["openshift.io/imported-from"])' > my-template.json
```

Attribute mit Wert `null` sowie die Annotation `openshift.io/generated-by` dürfen aus dem Template entfernt werden.

### Vorhandene Templates exportieren
Es können auch bestehende Templates der Plattform abgeholt werden um eigene Templates zu erstellen.

Verfügbare Templates sind im OpenShift Namespace hinterlegt. So werden alle Templates aufgelistet:
```
$ oc get templates -n openshift
```

So erhalten wir eine Kopie vom eap70-mysql-persistent-s2i Template:
```
$ oc export template eap70-mysql-persistent-s2i -o json -n openshift > eap70-mysql-persistent-s2i.json
```

## Parameter
Damit die Applikationen für die eigenen Bedürfnisse angepasst werden können, gibt es Parameter. Generierte oder exportierte Templates sollten fixe Werte, wie Hostnamen oder Passwörter, durch Parameter ersetzen.

### Parameter von Templates anzeigen
Mit **oc process --parameters** werden die Parameter eines Templates angezeigt. Hier wollen wir sehen, welche Paramter im CakePHP MySQL Template definiert sind:
```
$ oc process --parameters cakephp-mysql-example -n openshift
NAME                           DESCRIPTION                                                                GENERATOR VALUE
NAME                           The name assigned to all of the frontend objects defined in this template.           cakephp-mysql-example
NAMESPACE                      The OpenShift Namespace where the ImageStream resides.                               openshift
MEMORY_LIMIT                   Maximum amount of memory the CakePHP container can use.                              512Mi
MEMORY_MYSQL_LIMIT             Maximum amount of memory the MySQL container can use.                                512Mi
...
```

### Parameter von Templates mit Werten ersetzen
Für die Erzeugung der Applikationen können gewünschte Parameter mit Werten ersetzt werden. Dazu **oc process** verwenden:
```
oc process -f eap70-mysql-persistent-s2i.json \
  -v PARAM1=value1,PARAM2=value2 > processed-template.json
```
So werden Parameter vom Template mit den gegebenen Werten ersetzt und in eine neue Datei geschrieben. Diese Datei wird eine Liste von Resources/Items sein, welche mit **oc create** erstellt werden können:
```
oc create -f processed-template.json
```
Dies kann auch in einem Schritt erledigt werden:
```
oc process -f eap70-mysql-persistent-s2i.json \
  -v PARAM1=value1,PARAM2=value2 \
  | oc create -f -
```

## Templates schreiben
OpenShift Dokumentation:
* [Template Konzept](https://docs.openshift.com/container-platform/3.3/architecture/core_concepts/templates.html)
* [Templates schreiben](https://docs.openshift.com/container-platform/3.3/dev_guide/templates.html)

Applikationen sollten so gebaut werden, dass sich pro Umgebung nur ein paar Konfigurationen unterscheiden. Diese Werte werden im Template als Parameter definiert.
Somit ist der erste Schritt nach dem Generieren einer Template-Definition das Definieren von Parametern. Das Template wird mit Variablen erweitert, welche dann mit den Parameterwerten ersetzt werden. So wird die Variable `${DB_PASSWORD}` durch den Parameter mit Namen `DB_PASSWORD` ersetzt.

### Generierte Parameter
Oft werden Passwörter automatisch generiert, da der Wert nur im OpenShift Projekt verwendet wird. Dies kann mit einer Generate Definition erreicht werden.
```
parameters:
  - name: DB_PASSWORD
    description: "DB connection password"
    generate: expression
    from: "[a-zA-Z0-9]{13}"
```
Diese Definition würde ein zufälliges, 13 Zeichen langes Passwort mit Klein- und Grossbuchstaben sowie Zahlen generieren.

Auch wenn ein Parameter mit Generate Definition konfiguriert ist, kann er bei der Erzeugung überschrieben werden.

### Template Merge
Wenn z.B eine App mit einer Datenbank zusammen verwendet wird, können die zwei Templates zusammengelegt werden. Dabei ist es wichtig, die Template Parameter zu konsolidieren. Dies sind meistens Werte für die Anbindung der Datenbank. Dabei einfach in beiden Templates die gleiche Variable vom gemeinsamen Parameter verwenden.

## Anwenden vom Templates
Templates können mit `oc new-app -f <FILE>|<URL> -p <PARAM1>=<VALUE1>,<PARAM2>=<VALUE2>...` instanziert werden.
Wenn die Parameter des Templates bereits mit `oc process` gesetzt wurden, braucht es die Angabe der Parameter nicht mehr.

### Metadata / Labels
`oc new-app` fügt standardmässig das Label `app=<TEMPLATE NAME>` in alle instanzierten Ressourcen ein. Bei einigen OpenShift-Versionen kann dies zu [ungültigen](https://github.com/openshift/origin/issues/10782) Ressourcendefinitionen führen.
Als Workaround kann mit `oc new-app -l <LABEL NAME>=<LABEL VALUE> ...` ein alternatives Label konfiguriert werden.

## Ressourcen aus docker-compose.yml erstellen

Seit Version 3.3 bietet die OpenShift Container Platform die Möglichkeit, Ressourcen aus der Docker Compose Konfigurationdatei `docker-compose.yml` zu erstellen. Diese Funktionalität ist noch als experimentell eingestuft. Beispiel:
```
git clone -b techlab https://github.com/appuio/weblate-docker#techlab
oc import docker-compose -f docker-compose.yml -o json
```

Die Möglichkeit eine Datei direkt via URL zu importieren ist vorgesehen aber noch nicht implementiert. Durch Weglassen der Option `-o json` werden die Ressourcen direkt angelegt statt ausgegeben. Momentan werden Services für bereits vorhandene Docker Images nur angelegt, falls eine explizite Portkonfiguration in `docker-compose.yml` vorhanden ist. Diese können in der Zwischenzeit mithilfe von `oc new-app` angelegt werden:
```
oc new-app --name=database postgres:9.4 -o json|jq '.items[] | select(.kind == "Service")' | oc create -f -
oc new-app --name=cache memcached:1.4 -o json|jq '.items[] | select(.kind == "Service")'|oc create -f -
```

---

**Ende Lab 12**

[← zurück zur Übersicht](../README.md)
