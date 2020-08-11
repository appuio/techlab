# Cron Jobs in OpenShift

Kubernetes bringt das Konzept von Jobs und Cron Jobs mit.
Dies ermöglicht es, gewisse Tasks einmalig (Job) oder eben jeweils zu einer bestimmten Zeit (Cron Job) auszuführen.

Eine mögliche Auswahl von Anwendungsfällen:

- Jeweils um 23:12 ein Datenbank Backup erstellen und auf ein gemountetes PVC speichern
- Einmaliges generieren von Reports
- Cleanup-Job welcher alte Daten aufräumt
- Asynchrones Senden von Emails

## Job

Jobs im Unterschied zu einem Deployment, welches mittels Replication Controller getrackt wird, führt einen Pod einmalig aus bis der Befehl abgeschlossen ist.
Ein Job erstellt dafür einen Pod und führt die definierte Operation bzw. Befehl aus.
Es muss sich dabei nicht zwingend um nur einen Pod handeln, sondern kann auch mehrere beinhalten.
Wird ein Job gelöscht, werden auch die vom Job gestarteten (und wieder beendeten) Pods gelöscht.

Ein Job eignet sich also bspw. dafür, sicherzustellen, dass ein Pod verlässlich bis zu dessen Vervollständigung ausgeführt wird.
Schlägt ein Pod fehl, zum Beispiel wegen eines Node-Fehlers, startet der Job einen neuen Pod.

Weitere Informationen zu Jobs sind in der [OpenShift Dokumentation](https://docs.openshift.com/container-platform/latest/nodes/jobs/nodes-nodes-jobs.html) zu finden.

## Cron Jobs

Ein OpenShift Cron Job ist nichts anderes als eine Ressource, welche zu definierten Zeitpunkten einen Job erstellt, welcher wiederum wie gewohnt einen Pod startet um einen Befehl auszuführen.

Weitere Informationen zu Cron Jobs sind auf derselben [OpenShift Dokumentationsseite](https://docs.openshift.com/container-platform/latest/nodes/jobs/nodes-nodes-jobs.html) zu finden wie die Jobs.

## Aufgabe: Job für MariaDB-Dump erstellen

Ähnlich wie in [Lab-Aufgabe 9.4](../labs/09_database.md) wollen wir nun einen Dump der laufenden MariaDB-Datenbank erstellen, aber ohne uns in den Pod einloggen zu müssen.

Für dieses Beispiel verwenden wir das Spring Boot Beispiel aus [Lab 4](../labs/04_deploy_dockerimage.md), `[USERNAME]-dockerimage`.

<details><summary><b>Tipp</b></summary>oc project [USERNAME]-dockerimage</details>

Schauen wir uns zuerst die Job-Ressource an, die wir erstellen wollen.
Sie ist unter [additional-labs/resources/job_mariadb-dump.yaml](additional-labs/resources/job_mariadb-dump.yaml) zu finden.
Unter `.spec.template.spec.containers[0].image` sehen wir, dass wir dasselbe Image verwenden wie für die laufende Datenbank selbst.
Wir starten anschliessend aber keine Datenbank, sondern wollen einen `mysqldump`-Befehl ausführen, wie unter `.spec.template.spec.containers[0].command` aufgeführt.
Dazu verwenden wir, wie schon im Datenbank-Deployment, dieselben Umgebungsvariablen, um Hostname, User oder Passwort innerhalb des Pods definieren zu können.

Schlägt der Job fehl, soll er neugestartet werden, dies wird über die `restartPolicy` definiert.
Insgesamt soll 3 mal probiert werden den Job auszuführen (`backoffLimit`).

Erstellen wir nun also unseren Job:

```bash
oc create -f ./additional-labs/resources/job_mariadb-dump.yaml
```

Überprüfen wir, ob der Job erfolgreich war:

```bash
oc describe jobs/mariadb-dump
```

Den ausgeführten Pod können wir wie folgt anschauen:

```bash
oc get pods
```

Um alle Pods, welche zu einem Job gehören, in maschinenlesbarer Form auszugeben, kann bspw. folgender Befehl verwendet werden:

```bash
oc get pods --selector=job-name=mariadb-dump --output=jsonpath={.items..metadata.name}
```

Um zu überprüfen ob der Job erfolgreich war, können die Logs des Pod ausgelesen werden.

```bash
oc logs $(oc get pods --selector=job-name=mariadb-dump --output=jsonpath={.items..metadata.name})
```


## Aufgabe: Cron Job einrichten

In der vorherigen Aufgabe haben wir lediglich einen Job instanziert, welcher einmalig einen Datenbank Dump erstellt.
Nun wollen wir sicherstellen, dass dieser Datebank Dump nächtlich einmal ausgeführt wird.

Dafür erstellen wir nun eine Resource vom Typ Cron Job. Der Cron Job soll jeweils um 23:12 jeden Tag einen Job ausführen, welcher einen Dump der Datenbank erstellt und sichert.

```bash
oc create -f ./additional-labs/resources/cronjob_mariadb-dump.yaml
```

Schauen wir uns nun diesen Cron Job an:

```bash
oc get cronjob mariadb-backup -o yaml
```

__Wichtig__:
Beachten Sie, dass insbesondere Backups überwacht und durch Restore Tests überprüft werden müssen.
Diese Logik kann bspw. in den auszuführenden Befehl integriert oder aber durch ein Monitoring Tool übernommen werden.
Im Test-Cron Job wird der Dump in das `/tmp`-Verzeichnis geschrieben.
Für den produktiven Einsatz sollte dies ein gemountetes Persistent Volume sein.

Versuchen Sie, folgende Fragen zu beantworten:

- Wann wurde der Cron Job das letzte mal ausgeführt?
- War das Backup erfolgreich?
- Konnten die Daten erfolgreich restored werden?

__Ende Lab Cron Jobs__

[← zurück zur Übersicht](../README.md)
