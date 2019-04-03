# ConfigMap

ConfigMaps werden dazu verwendet, die Konfiguration für eine Applikation vom Image zu trennen und bei Laufzeit dem Pod zur Verfügung zu stellen, ähnlich dem Setzen von Umgebungsvariablen. Dies erlaubt es, Applikationen innerhalb von Containern möglichst portabel zu halten.

In diesem Lab lernen Sie, wie man ConfigMaps erstellt und entsprechend verwendet.

# ConfigMap in OpenShift Projekt anlegen:

Um eine ConfigMap in einem Projekt anzulegen kann folgender Befehl verwendet werden:

```bash
$ oc create configmap [Name der ConfigMap] [Options]
```


## Java properties Files als ConfigMap

Ein klassisches Beispiel für ConfigMaps sind Property Files bei Java Applikationen, welche in erster Linie nicht via Umgebungsvariablen konfiguriert werden können.

Für dieses Beispiel verwenden wir das Spring Boot Beispiel aus [LAB 4](../labs/04_deploy_dockerimage.md), `[USER]-dockerimage`. **Tipp:** `oc project [USER]-dockerimage`

Mit dem folgenden Befehl legen wir nun die erste ConfigMap auf Basis eines lokalen Files an:

```
$ oc create configmap javaconfiguration --from-file=additional-labs/resources/properties.properties
```

Mit

```
$ oc get configmaps
NAME                DATA   AGE
javaconfiguration   1      7s
```
kann nun verifiziert werden ob die ConfigMap erfolgreich angelegt wurde.

Oder mittels `$ oc get configmaps javaconfiguration -o json` kann der Inhalt angezeigt werden.


## Configmap in Pod zur Verfügung stellen

Als nächstes wollen wir die ConfigMap im Pod verfügbar machen.

Grundsätzlich gibt es dafür die folgenden Möglichkeiten, welche in der [offiziellen Dokumentation](https://docs.openshift.com/container-platform/3.11/dev_guide/configmaps.html#consuming-configmap-in-pods) genauer beschrieben werden:


* ConfigMap Properties als Umgebungsvariablen im Deployment
* Commandline Arguments via Umgebungsvariablen
* als Volumes in den Container gemountet

Im Beispiel hier wollen wir, dass das File als File auf einem Volume liegt.

Hierfür müssen wir entweder den Pod oder in unserem Fall das Deployment mit `oc edit dc example-spring-boot` bearbeiten.

Zu beachten gilt es dabei den volumeMounts- (`spec.template.spec.containers.volumeMounts`: wie wird das Volume in den Container gemountet) sowie den volumes-Teil (`spec.template.spec.volumes`: welches Volume in unserem Fall die ConfigMap wird in den Container gemountet).

```
apiVersion: v1
kind: DeploymentConfig
metadata:
  annotations:
    openshift.io/generated-by: OpenShiftNewApp
  creationTimestamp: 2018-12-05T08:24:06Z
  generation: 2
  labels:
    app: example-spring-boot
  name: example-spring-boot
  namespace: [namespace]
  resourceVersion: "149323448"
  selfLink: /oapi/v1/namespaces/[namespace]/deploymentconfigs/example-spring-boot
  uid: 21f6578b-f867-11e8-b72f-001a4a026f33
spec:
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    app: example-spring-boot
    deploymentconfig: example-spring-boot
  strategy:
    activeDeadlineSeconds: 21600
    resources: {}
    rollingParams:
      intervalSeconds: 1
      maxSurge: 25%
      maxUnavailable: 25%
      timeoutSeconds: 600
      updatePeriodSeconds: 1
    type: Rolling
  template:
    metadata:
      annotations:
        openshift.io/generated-by: OpenShiftNewApp
      creationTimestamp: null
      labels:
        app: example-spring-boot
        deploymentconfig: example-spring-boot
    spec:
      containers:
      - env:
        - name: SPRING_DATASOURCE_USERNAME
          value: appuio
        - name: SPRING_DATASOURCE_PASSWORD
          value: appuio
        - name: SPRING_DATASOURCE_DRIVER_CLASS_NAME
          value: com.mysql.jdbc.Driver
        - name: SPRING_DATASOURCE_URL
          value: jdbc:mysql://mysql/appuio?autoReconnect=true
        image: appuio/example-spring-boot
        imagePullPolicy: Always
        name: example-spring-boot
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/config
          name: config-volume
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          defaultMode: 420
          name: javaconfiguration
        name: config-volume

```

Anschliessend kann im Container im File `/etc/config/properties.properties` auf die Werte zugegriffen werden.

```bash
$ oc exec [POD] cat /etc/config/properties.properties
key=appuio
key2=openshift
```

Diese Property File kann nun so von der Java Applikation im Container gelesen und verwendet werden. Das Image bleibt dabei umgebungsneutral.

## Aufgabe: LAB10.4.1 ConfigMap Data Sources

Erstellen Sie jeweils eine ConfigMap und verwenden Sie dafür die verschiedenen Arten von [Data Sources](https://docs.openshift.com/container-platform/3.11/dev_guide/configmaps.html#consuming-configmap-in-pods).

Machen Sie die Werte innerhalb von Pods auf die unterschiedlichen Arten verfügbar.


---


**Ende**

[← zurück zur Übersicht](../README.md)
