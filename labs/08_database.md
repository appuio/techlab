# Lab 8: Datenbank anbinden

Die meisten Applikationen sind in irgend einer Art stateful und speichern Daten persistent ab. Sei dies in einer Datenbank oder als Files auf einem Filesystem oder Objectstore. In diesem Lab werden wir in unserem Projekt einen MySQL Service anlegen und an unsere Applikation anbinden, sodass mehrere Applikationspods auf die gleiche Datenbank zugreifen können.

Für dieses Beispiel verwenden wir das Spring Boot Beispiel aus [LAB 4](04_deploy_dockerimage.md), `[USER]-dockerimage`. **Tipp:** `oc project [USER]-dockerimage`

## Aufgabe: LAB8.1: MySQL Service anlegen

Für unser Beispiel verwenden wir in diesem Lab ein OpenShift Template, welches eine MySQL Datenbank mit EmptyDir Data Storage anlegt. Dies ist nur für Testumgebungen zu verwenden, da beim Restart des MySQL Pods alle Daten verloren gehen. In einem späteren Lab werden wir aufzeigen, wie wir ein Persistent Volume (mysql-persistent) an die MySQL Datenbank anhängen. Damit bleiben die Daten auch bei Restarts bestehen und ist so für den produktiven Betrieb geeignet.

Den MySQL Service können wir sowohl über die Web Console als auch über das CLI anlegen.

Um dasselbe Ergebnis zu erhalten müssen lediglich Datenbankname, Username, Password und DatabaseServiceName gleich gesetzt werden, egal welche Variante verwendet wird:

- MYSQL_USER appuio
- MYSQL_PASSWORD appuio
- MYSQL_DATABASE appuio
- DATABASE_SERVICE_NAME mysql

### CLI

Über das CLI kann der MySQL Service wie folgt angelegt werden:

```
$ oc new-app mysql-ephemeral \
     -pMYSQL_USER=appuio \
     -pMYSQL_PASSWORD=appuio \
     -pMYSQL_DATABASE=appuio
```

### Web Console

In der Web Console kann der MySQL (Ephemeral) Service via Catalog dem Projekt hinzugefügt werden. Dazu oben rechts auf *Add to Project*, *Browse Catalog* klicken und anschliessend unter dem Reiter *Databases* *MySQL* und *MySQL (Ephemeral)* auswählen:

![MySQLService](../images/lab_8_mysql.png)

### Passwort und Username als Plaintext?

Beim Deployen der Datebank via CLI wie auch via Web Console haben wir mittels Parameter Werte für User, Passwort und Datenbank angegeben. In diesem Kapitel wollen wir uns nun anschauen, wo diese sensitiven Daten effektiv gelandet sind.

Schauen wir uns als erstes die DeploymentConfig der Datenbank an:

```bash
$ oc get dc mysql -o yaml
```

Konkret geht es um die Konfiguration der Container mittels env (MYSQL_USER, MYSQL_PASSWORD, MYSQL_ROOT_PASSWORD, MYSQL_DATABASE) in der DeploymentConfig unter `spec.templates.spec.containers`:

```yaml
    spec:
      containers:
      - env:
        - name: MYSQL_USER
          valueFrom:
            secretKeyRef:
              key: database-user
              name: mysql
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-password
              name: mysql
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              key: database-root-password
              name: mysql
        - name: MYSQL_DATABASE
          valueFrom:
            secretKeyRef:
              key: database-name
              name: mysql
```

Die Werte für die einzelnen Umgebungsvariablen kommen also aus einem sogenannten Secret, in unserem Fall hier aus dem Secret mit Namen `mysql`. In diesem Secret sind die vier Werte entsprechend unter den passenden Keys (`database-user`, `database-password`, `database-root-password`, `database-name`) abgelegt und können so referenziert werden.

Schauen wir uns nun die neue Ressource Secret mit dem Namen `mysql` an:

```bash
$ oc get secret mysql -o yaml
```

Die entsprechenden Key-Value Pairs sind unter `data` ersichtlich:

```yaml
apiVersion: v1
data:
  database-name: 
  database-password: YXBwdWlv
  database-root-password: dDB3ZDFLRFhsVjhKMGFHQw==
  database-user: YXBwdWlv
kind: Secret
metadata:
  annotations:
    openshift.io/generated-by: OpenShiftNewApp
    template.openshift.io/expose-database_name: '{.data[''database-name'']}'
    template.openshift.io/expose-password: '{.data[''database-password'']}'
    template.openshift.io/expose-root_password: '{.data[''database-root-password'']}'
    template.openshift.io/expose-username: '{.data[''database-user'']}'
  creationTimestamp: 2018-12-04T10:33:43Z
  labels:
    app: mysql-ephemeral
    template: mysql-ephemeral-template
  name: mysql
  ...
type: Opaque
```

Die konkreten Werte sind base64-kodiert. Unter Linux oder in der Gitbash kann man sich den entsprechenden Wert einfach mittels:

```bash
$ echo "YXBwdWlv" | base64 -d
appuio
```
anzeigen lassen. In userem Fall wird `YXBwdWlv` in `appuio` dekodiert.

Mit Secrets können wir also sensitive Informationen (Credetials, Zertifikate, Schlüssel, dockercfg, ...) abspeichern und entsprechend von den Pods entkoppeln. Gleichzeitig haben wir damit die Möglichkeit, dieselben Secrets in mehreren Containern zu verwenden und so Redundanzen zu vermeiden.

Secrets können entweder, wie oben bei der MySQL-Datenbank, in Umgebungsvariablen gemappt oder direkt als Files via Volumes in einen Container gemountet werden.

Weitere Informationen zu Secrets können in der [offiziellen Dokumentation](https://docs.openshift.com/container-platform/3.9/dev_guide/secrets.html) gefunden werden.

## Aufgabe: LAB8.2: Applikation an die Datenbank anbinden

Standardmässig wird bei unserer example-spring-boot Applikation eine H2 Memory Datenbank verwendet. Dies kann über das Setzen der folgenden Umgebungsvariablen entsprechend auf unseren neuen MySQL Service umgestellt werden:

- SPRING_DATASOURCE_USERNAME appuio
- SPRING_DATASOURCE_PASSWORD appuio
- SPRING_DATASOURCE_DRIVER_CLASS_NAME com.mysql.jdbc.Driver
- SPRING_DATASOURCE_URL jdbc:mysql://[Adresse des MySQL Service]/appuio?autoReconnect=true

Für die Adresse des MySQL Service können wir entweder dessen Cluster IP (`oc get service`) oder aber dessen DNS-Namen (`<service>`) verwenden. Alle Services und Pods innerhalb eines Projektes können über DNS aufgelöst werden.

So lautet der Wert für die Variable SPRING_DATASOURCE_URL bspw.:
```
Name des Services: mysql

jdbc:mysql://mysql/appuio?autoReconnect=true
```

Diese Umgebungsvariablen können wir nun in der DeploymentConfig example-spring-boot setzen. Nach dem **ConfigChange** (ConfigChange ist in der DeploymentConfig als Trigger registriert) wird die Applikation automatisch neu deployed. Aufgrund der neuen Umgebungsvariablen verbindet die Applikation an die MySQL DB und [Liquibase](http://www.liquibase.org/) kreiert das Schema und importiert die Testdaten.

**Note:** Liquibase ist Open Source. Es ist eine Datenbank unabhängige Library um Datenbank Änderungen zu verwalten und auf der Datenbank anzuwenden. Liquibase erkennt beim Startup der Applikation, ob DB Changes auf der Datenbank angewendet werden müssen oder nicht. Siehe Logs.


```
SPRING_DATASOURCE_URL=jdbc:mysql://mysql/appuio?autoReconnect=true
```
**Note:** mysql löst innerhalb Ihres Projektes via DNS Abfrage auf die Cluster IP des MySQL Service auf. Die MySQL Datenbank ist nur innerhalb des Projektes erreichbar. Der Service ist ebenfalls über den folgenden Namen erreichbar:

```
Projektname = techlab-dockerimage

mysql.techlab-dockerimage.svc.cluster.local
```

Befehl für das Setzen der Umgebungsvariablen:
```
 $ oc env dc example-spring-boot \
      -e SPRING_DATASOURCE_URL="jdbc:mysql://mysql/appuio?autoReconnect=true" \
      -e SPRING_DATASOURCE_USERNAME=appuio \ 
	  -e SPRING_DATASOURCE_PASSWORD=appuio \
      -e SPRING_DATASOURCE_DRIVER_CLASS_NAME=com.mysql.jdbc.Driver
```

Über den folgenden Befehl können Sie sich die DeploymentConfig als JSON anschauen. Neu enthält die Config auch die gesetzten Umgebungsvariablen:

```
 $ oc get dc example-spring-boot -o json
```

```
...
 "env": [
	        {
	            "name": "SPRING_DATASOURCE_USERNAME",
	            "value": "appuio"
	        },
	        {
	            "name": "SPRING_DATASOURCE_PASSWORD",
	            "value": "appuio"
	        },
	        {
	            "name": "SPRING_DATASOURCE_DRIVER_CLASS_NAME",
	            "value": "com.mysql.jdbc.Driver"
	        },
	        {
	            "name": "SPRING_DATASOURCE_URL",
	            "value": "jdbc:mysql://mysql/appuio"
	        }
	    ],
...
```

Die Konfiguration kann auch in der Web Console angeschaut und verändert werden:

(Applications → Deployments → example-spring-boot, Actions, Edit YAML)

## Aufgabe: LAB8.2.1: Setzen der Werte für Usernamen und Passwort aus dem Secret mysql

Weiter oben haben wir gesehen, wie OpenShift mittels Secrets senisitive Informationen von der eigentlichen Konfiguration enkoppelt und uns dabei hilft Redundanzen zu vermeiden. Unsere Springboot Applikation aus dem vorherigen Lab haben wir zwar korrekt konfiguriert, allerings aber die Werte redundant und plaintext in der DeploymentConfig abgelegt.

Passen wir nun die DeploymentConfig example-spring-boot so an, dass die Werte aus den Secrets verwendet werden. Zu beachten gibt es die Konfiguration der Container unter `spec.template.spec.containers`

Mittels `oc edit dc example-spring-boot -o json` kann die DeploymentConfig als Json wie folgt bearbeitet werden.
```
...
"env": [
			{
				"name": "SPRING_DATASOURCE_USERNAME",
				"valueFrom": {
					"secretKeyRef": {
						"key": "database-user",
						"name": "mysql"
					}
				}
			},
			{
				"name": "SPRING_DATASOURCE_PASSWORD",
				"valueFrom": {
					"secretKeyRef": {
						"key": "database-password",
						"name": "mysql"
					}
				}
			},
			{
	            "name": "SPRING_DATASOURCE_DRIVER_CLASS_NAME",
	            "value": "com.mysql.jdbc.Driver"
	        },
	        {
	            "name": "SPRING_DATASOURCE_URL",
	            "value": "jdbc:mysql://mysql/appuio"
	        }
		],

...
```

Nun werden die Werte für Usernamen und Passwort sowohl beim mysql Pod wie auch beim Springboot Pod aus dem selben Secret gelesen.


## Aufgabe: LAB8.3: In MySQL Service Pod einloggen und manuell auf DB verbinden

Wie im Lab [07](07_troubleshooting_ops.md) beschrieben kann mittels `oc rsh [POD]` in einen Pod eingeloggt werden:
```
$ oc get pods
NAME                           READY     STATUS             RESTARTS   AGE
example-spring-boot-8-wkros    1/1       Running            0          10m
mysql-1-diccy                  1/1       Running            0          50m

```

Danach in den MySQL Pod einloggen:
```
$ oc rsh mysql-1-diccy
```

Nun können Sie mittels mysql Tool auf die Datenbank verbinden und die Tabellen anzeigen:
```
$ mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_SERVICE_HOST appuio
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 54
Server version: 5.6.26 MySQL Community Server (GPL)

Copyright (c) 2000, 2015, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

Anschliessend können Sie mit
```
show tables;
```

alle Tabellen anzeigen.


## Aufgabe: LAB8.4: Dump auf MySQL DB einspielen

Die Aufgabe ist es, in den MySQL Pod den [Dump](https://raw.githubusercontent.com/appuio/techlab/lab-3.3/labs/data/08_dump/dump.sql) einzuspielen.


**Tipp:** Mit `oc rsync` können Sie lokale Dateien in einen Pod kopieren.

**Achtung:** Beachten Sie, dass dabei der rsync-Befehl des Betriebssystems verwendet wird. Auf UNIX-Systemen kann rsync mit dem Paketmanager, auf Windows kann bspw. [cwRsync](https://www.itefix.net/cwrsync) installiert werden. Ist eine Installation von rsync nicht möglich, kann stattdessen bspw. in den Pod eingeloggt und via `curl -O <URL>` der Dump heruntergeladen werden.

**Tipp:** Verwenden Sie das Tool mysql um den Dump einzuspielen.

**Tipp:** Die bestehende Datenbank muss vorgängig leer sein. Sie kann auch gelöscht und neu angelegt werden.


---

## Lösung: LAB8.4

Ein ganzes Verzeichnis (dump) syncen. Darin enthalten ist das File `dump.sql`. Beachten Sie zum rsync-Befehl auch obenstehenden Tipp sowie den fehlenden trailing slash.
```
oc rsync ./labs/data/08_dump mysql-1-diccy:/tmp/
```
In den MySQL Pod einloggen:

```
$ oc rsh mysql-1-diccy
```

Bestehende Datenbank löschen:
```
$ mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_SERVICE_HOST appuio
...
mysql> drop database appuio;
mysql> create database appuio;
mysql> exit
```
Dump einspielen:
```
$ mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -h$MYSQL_SERVICE_HOST appuio < /tmp/08_dump/dump.sql
```

**Note:** Den Dump kann man wie folgt erstellen:

```
mysqldump --user=$MYSQL_USER --password=$MYSQL_PASSWORD --host=$MYSQL_SERVICE_HOST appuio > /tmp/dump.sql
```


---

**Ende Lab 8**

<p width="100px" align="right"><a href="09_dockerbuild_webhook.md">Code Änderungen via Webhook direkt integrieren →</a></p>

[← zurück zur Übersicht](../README.md)
