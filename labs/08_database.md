# Lab 8: Deploy and Attach a Database

Most Applications are in a way stateful and safe their Data persistent in a Database, as a file or in a objectstore. In this Lab we will add an MySQL Service to our Project and attach it, so that multiple application pods can access the same database.

As an Example we use our Springboot App from [LAB 4](04_deploy_dockerimage.md), `[USER]-dockerimage`. **Hint:** `oc project [USER]-dockerimage`

## Task: LAB8.1: Create a MySQL service

For our Example in this Lab we use an OpenShift Template which will create a MySQL Database with an EmptyDir Data Storage. This Setup is only recommended for test environements since all the Data is lost if the MySQL Pod is restarted. In a later Lab we will show you how to create a persistent volume for the Databank, so that the data doesn't get lost if the pod restarts.

The MySQL Service can be created in the Web Console as well as the CLI

To get the same result one simply has to set the database name, username, password and DatabaseServiceName regardless of the method:

- MYSQL_USER appuio
- MYSQL_PASSWORD appuio
- MYSQL_DATABASE appuio
- DATABASE_SERVICE_NAME mysql

### CLI

Using the cli the MySQL Service can be created as follows:

```
$ oc new-app mysql-ephemeral \
     -pMEMORY_LIMIT=256Mi \
     -pMYSQL_USER=appuio -pMYSQL_PASSWORD=appuio \
     -pMYSQL_DATABASE=appuio -pDATABASE_SERVICE_NAME=mysql
```

### Web Console
In the Web Console one can create the MySQL (Ephemeral) Service via "Add to Project" -> "Data Stores":
![MySQLService](../images/lab_8_addmysql_service.png)


## Task: LAB8.2: Applikation an die Datenbank anbinden

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
      -e SPRING_DATASOURCE_USERNAME=appuio -e SPRING_DATASOURCE_PASSWORD=appuio \
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

## Task: LAB8.3: In MySQL Service Pod einloggen und manuell auf DB verbinden

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


## Task: LAB8.4: Dump auf MySQL DB einspielen

Die Task ist es, in den MySQL Pod den [Dump](https://raw.githubusercontent.com/appuio/techlab/lab-3.3/labs/data/08_dump/dump.sql) einzuspielen.


**Hint:** Mit `oc rsync` können Sie lokale Dateien in einen Pod kopieren.

**Achtung:** Beachten Sie, dass dabei der rsync-Befehl des Betriebssystems verwendet wird. Auf UNIX-Systemen kann rsync mit dem Paketmanager, auf Windows kann bspw. [cwRsync](https://www.itefix.net/cwrsync) installiert werden. Ist eine Installation von rsync nicht möglich, kann stattdessen bspw. in den Pod eingeloggt und via `curl -O <URL>` der Dump heruntergeladen werden.

**Hint:** Verwenden Sie das Tool mysql um den Dump einzuspielen.

**Hint:** Die bestehende Datenbank muss vorgängig leer sein. Sie kann auch gelöscht und neu angelegt werden.


---

## Lösung: LAB8.4

Ein ganzes Verzeichnis (dump) syncen. Darin enthalten ist das File `dump.sql`. Beachten Sie zum rsync-Befehl auch obenstehenden Hint sowie den fehlenden trailing slash.
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

[← back to overview](../README.md)
