# Lab 10: Persistent Storage anbinden und verwenden für Datenbank

Per se sind Daten in einem Pod nicht persistent, was u.a. auch in unserem Beispiel der Fall ist. Verschwindet also unser MySQL-Pod bspw. aufgrund einer Änderung des Image, sind die bis zuvor noch vorhandenen Daten im neuen Pod nicht mehr vorhanden. Um genau dies zu verhindern hängen wir nun Persistent Storage an unseren MySQL-Pod an.

## Aufgabe: LAB10.1: 

### Storage anfordern

Um für einen Pod persistenten Speicher zu erhalten, müssen wir diesen zuerst für das Projekt anfordern. Dies geschieht anhand eines sog. PersistentVolumeClaim. Dieser PersistentVolumeClaim wird anschliessend mit einem zur Verfügung stehenden Persistent Volume verbunden, wodurch dieses dann über den Claim verwendet werden kann.

Wir erstellen den PVC wie folgt:
```
$ cat <<-EOF | oc create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysqlpvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 256Mi
EOF
```

**Note:** Dies ist zugleich auch das erste Mal, dass wir mit dem Befehl `oc create` arbeiten. Mit ihm sind wir in der Lage, beliebige Objekte erstellen zu lassen; über das Attribut "kind" weiss OpenShift, welche Art von Objekt es erstellen muss.

Mit dem Befehl `oc get persistentvolumeclaim`, oder etwas einfacher `oc get pvc`, können wir die im Projekt vorhandenen PersistentVolumeClaims anzeigen lassen:
```
$ oc get pvc
NAME       LABELS    STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
mysqlpvc   <none>    Bound     pv18      256Mi      RWO,RWX       3m
```
Die beiden Attribute Status und Volume zeigen uns bereits an, dass unser Claim mit dem Persistent Volume pv18 verbunden wurde.


### Volume in Pod einbinden

Nun fehlt nur noch, den erstellten PVC tatsächlich auch in einen Pod einzubinden. In Lab 6 bearbeiteten wir die Deployment Config, um die Readiness Probe einzufügen. Dasselbe tun wir nun für das Persistent Volume. Im Unterschied zu Lab 6 können wir aber mit `oc volume` die Deployment Config bearbeiten, und zwar so:
```
$ oc volume dc/mysql --add --name=mysql-data --type pvc --claim-name=mysqlpvc --overwrite
```
**Note:** Durch die veränderte Deployment Config deployed OpenShift automatisch einen neuen Pod. D.h. leider auch, dass das vorher erstellte DB-Schema und bereits eingefügte Daten verloren gegangen sind.


## Aufgabe: LAB10.2: Persistenz-Test

### Daten wiederherstellen

Wiederholen Sie [Lab-Aufgabe 8.4](08_database.md).


### Test
Skalieren Sie nun den Pod auf 0 und anschliessend wieder auf 1. Beobachten Sie, dass der neue Pod die Daten nun nicht verloren hat.


---

**Ende Lab 10**

[<< zurück zur Übersicht] (../README.md)

