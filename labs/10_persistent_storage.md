# Lab 10: Persistent Storage anbinden und verwenden für Datenbank

Per se sind Daten in einem Pod nicht persistent, was u.a. auch in unserem Beispiel der Fall ist. Verschwindet also unser MySQL-Pod bspw. aufgrund einer Änderung des Images, sind die bis zuvor noch vorhandenen Daten im neuen Pod nicht mehr vorhanden. Um genau dies zu verhindern hängen wir nun Persistent Storage an unseren MySQL-Pod an.

## Aufgabe: LAB10.1:

### Storage anfordern

Das Anhängen von Persistent Storage geschieht eigentlich in zwei Schritten. Der erste Schritt beinhaltet als erstes das Erstellen eines sog. PersistentVolumeClaim für unser Projekt. Im Claim definieren wir u.a. dessen Namen sowie Grösse, also wie viel persistenten Speicher wir überhaupt haben wollen.

Der PersistentVolumeClaim stellt allerdings erst den Request dar, nicht aber die Ressource selbst. Er wird deshalb automatisch durch OpenShift mit einem zur Verfügung stehenden Persistent Volume verbunden, und zwar mit einem mit mindestens der angeforderten Grösse. Sind nur noch grössere Persistent Volumes vorhanden, wird eines dieser Volumes verwendet und die Grösse des Claims angepasst. Sind nur noch kleinere Persistent Volumes vorhanden, kann der Claim nicht verbunden werden und bleibt solange offen, bis ein Volume der passenden Grösse (oder eben grösser) auftaucht.


### Volume in Pod einbinden

Im zweiten Schritt wird der zuvor erstellte PVC im richtigen Pod eingebunden. In [LAB 6](06_scale.md) bearbeiteten wir die Deployment Config, um die Readiness Probe einzufügen. Dasselbe tun wir nun für das Persistent Volume. Im Unterschied zu [LAB 6](06_scale.md) können wir aber mit `oc volume` die Deployment Config automatisch erweitern.

Wir verwenden dafür wieder das Projekt aus [LAB 8](08_database.md) [USER]-dockerimage. **Tipp:** `oc project [USER]-dockerimage`

Der folgende Befehl führt beide beschriebenen Schritte zugleich aus, er erstellt also zuerst den Claim und bindet ihn anschliessend auch als Volume im Pod ein:
```
$ oc volume dc/mysql --add --name=mysql-data --type persistentVolumeClaim \
     --claim-name=mysqlpvc --claim-size=256Mi --overwrite
```
**Note:** Durch die veränderte Deployment Config deployt OpenShift automatisch einen neuen Pod. D.h. leider auch, dass das vorher erstellte DB-Schema und bereits eingefügte Daten verloren gegangen sind.

Unsere Applikation erstellt beim Starten das DB Schema eigenständig.

**Tipp:** redeployen Sie den Applikations-Pod:

```
$ oc rollout latest example-spring-boot
```

Mit dem Befehl `oc get persistentvolumeclaim`, oder etwas einfacher `oc get pvc`, können wir uns nun den im Projekt frisch erstellten PersistentVolumeClaim anzeigen lassen:
```
$ oc get pvc
NAME       STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
mysqlpvc   Bound     pv34      256Mi      RWO,RWX       14s
```
Die beiden Attribute Status und Volume zeigen uns an, dass unser Claim mit dem Persistent Volume pv34 verbunden wurde.

Mit dem folgenden Befehl können wir auch noch überprüfen, ob das Einbinden des Volumes in die Deployment Config geklappt hat:
```
$ oc volume dc/mysql
deploymentconfigs/mysql
  pvc/mysqlpvc (allocated 256MiB) as mysql-data
```

## Aufgabe: LAB10.2: Persistenz-Test

### Daten wiederherstellen

Wiederholen Sie [Lab-Aufgabe 8.4](08_database.md#l%C3%B6sung-lab84).


### Test

Skalieren Sie nun den mysql Pod auf 0 und anschliessend wieder auf 1. Beobachten Sie, dass der neue Pod die Daten nicht mehr verliert.

---

**Ende Lab 10**

<p width="100px" align="right"><a href="11_template.md">Applikationstemplates →</a></p>

[← zurück zur Übersicht](../README.md)
