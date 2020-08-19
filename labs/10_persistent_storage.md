# Lab 10: Persistent Storage anbinden und verwenden für Datenbank

Per se sind Daten in einem Pod nicht persistent, was u.a. auch in unserem Beispiel der Fall ist.
Verschwindet also unser MariaDB-Pod bspw. aufgrund einer Änderung des Image, sind die bis zuvor noch vorhandenen Daten im neuen Pod nicht mehr vorhanden.
Um genau dies zu verhindern hängen wir nun Persistent Storage an unseren MariaDB-Pod an.

## Aufgabe 1: Persistent Storage anbinden

### Storage anfordern

Das Anhängen von Persistent Storage geschieht eigentlich in zwei Schritten.
Der erste Schritt beinhaltet als erstes das Erstellen eines sog. PersistentVolumeClaim für unser Projekt.
Im Claim definieren wir u.a. dessen Namen sowie Grösse, also wie viel persistenten Speicher wir überhaupt haben wollen.

Der PersistentVolumeClaim stellt allerdings erst den Request dar, nicht aber die Ressource selbst.
Er wird deshalb automatisch durch OpenShift mit einem zur Verfügung stehenden Persistent Volume verbunden, und zwar mit einem mit mindestens der angeforderten Grösse.
Sind nur noch grössere Persistent Volumes vorhanden, wird eines dieser Volumes verwendet und die Grösse des Claim angepasst.
Sind nur noch kleinere Persistent Volumes vorhanden, kann der Claim nicht erfüllt werden und bleibt solange offen, bis ein Volume der passenden Grösse (oder eben grösser) auftaucht.


### Volume in Pod einbinden

Im zweiten Schritt wird der zuvor erstellte PVC im richtigen Pod eingebunden.
In [Lab 6](06_scale.md) bearbeiteten wir die DeploymentConfig, um die Readiness Probe einzufügen.
Dasselbe tun wir nun für das Persistent Volume.
Im Unterschied zu [Lab 6](06_scale.md) können wir aber mit `oc set volume` die DeploymentConfig automatisch erweitern.

Wir verwenden dafür das Projekt aus [Lab 9](09_database.md) [USERNAME]-dockerimage.

<details><summary><b>Tipp</b></summary>oc project [USERNAME]-dockerimage</details><br/>

Der folgende Befehl führt beide beschriebenen Schritte zugleich aus, er erstellt also zuerst den Claim und bindet ihn anschliessend auch als Volume im Pod ein:

```bash
oc set volume dc/mariadb --add --name=mariadb-data --type pvc \
  --claim-name=mariadbpvc --claim-size=256Mi --overwrite
```

__Note__:
Durch die veränderte DeploymentConfig deployt OpenShift automatisch einen neuen Pod.
D.h. leider auch, dass das vorher erstellte DB-Schema und bereits eingefügte Daten verloren gegangen sind.

Unsere Applikation erstellt beim Starten das DB Schema eigenständig.

__Tipp__:
Redeployen Sie den Applikations-Pod mit:

```bash
oc rollout latest example-spring-boot
```

Mit dem Befehl `oc get persistentvolumeclaim`, oder etwas einfacher `oc get pvc`, können wir uns nun den im Projekt frisch erstellten PersistentVolumeClaim anzeigen lassen:

```
oc get pvc
NAME         STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
mariadbpvc   Bound     pv34      1Gi        RWO,RWX       14s
```

Die beiden Attribute Status und Volume zeigen uns an, dass unser Claim mit dem Persistent Volume pv34 verbunden wurde.

Mit dem folgenden Befehl können wir auch noch überprüfen, ob das Einbinden des Volume in die DeploymentConfig geklappt hat:

```bash
oc set volume dc/mariadb --all
deploymentconfigs/mariadb
  pvc/mariadbpvc (allocated 1GiB) as mariadb-data
    mounted at /var/lib/mysql/data
```


## Aufgabe 2: Persistenz-Test
### Daten wiederherstellen

Wiederholen Sie [Lab-Aufgabe 9.4](09_database.md#l%C3%B6sung-lab84).


### Test

Skalieren Sie nun den MariaDB-Pod auf 0 und anschliessend wieder auf 1. Beobachten Sie, dass der neue Pod die Daten nicht mehr verliert.

---

__Ende Lab 10__

<p width="100px" align="right"><a href="11_dockerbuild_webhook.md">Code Änderungen via Webhook direkt integrieren →</a></p>

[← zurück zur Übersicht](../README.md)
