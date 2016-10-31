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

Übersicht aller Resourcen:
```
$ oc get all
```

Infos zu einer Resource:
```
$ oc get <RESOURCE_TYPE> <RESOURCE_NAME>
$ oc describe <RESOURCE_TYPE> <RESOURCE_NAME>
```

## Generierung
Über "oc new-app" oder "Add to project" in der Web Konsole werden die Resourcen automatisch angelegt. In der Web Konsole kann die Erstellung einfach Konfiguriert werden.

Für den produktiven Einsatz reicht das meinstens nicht aus. Da braucht es mehr Kontrolle über die Konfiguration. Dazu sind eigene Templates die Lösung. Sie müssen jedoch nicht von Hand geschrieben werden sondern können als Vorlage generiert werden.

### oc new-app
OpenShift parst die gegebenen Images, Templates, Source Code Repositories usw. und erstellt die Resourcen Definitionen. Mit der Option **-o** erhält man die Definitionen ohne dass die Resourcen angelegt werden.

So sieht die Definition vom hello-world Image aus.
```
$ oc new-app hello-world -o json
```

Spannend ist auch zu schauen, was OpenShift aus einem eigenen Projekt machen würde. Dafür ein Git Repository oder einen lokalen Pfad vom Rechner angeben.

Beispiel Befehl, wenn man sich im Root Ordner vom Projekt befindet:
```
$ oc new-app . -o json
```
Wenn verschiede Imagestreams in Frage kommen könnten oder keiner gefunden wurde, muss er angeben werden:
```
$ oc new-app . --image-stream=wildfly:latest -o json
```

Der Output der Konsole beginnt immer mit dem Kind: List.
```
{
    "kind": "List",
    "apiVersion": "v1",
    ...
```
Dies muss für ein Template in *template* geändert werden.


* oc export
 * welche Resourcen exportieren?
 * welche Teile behalten?
 * was Anpassen?

## Parameter
* process
* generate
 * Definition
* int param

## Template Merge

## Imagestream Varianten
* mit oder ohne automatischem Update

## Metadata
* Labels

## Docker swarm2kube



---

**Ende Lab 12**

[<< zurück zur Übersicht] (../README.md)
