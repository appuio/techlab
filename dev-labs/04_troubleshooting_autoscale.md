# Troubleshooting und Autoscaling

In diesen Labs werden wir Applikationen autoscalen und troubleshooten.

## Troubleshooting

Folgen Sie den Anweisungen im [Lab 8: Troubleshooting](../labs/08_troubleshooting_ops.md).

## Autoscaling

In diesem Beispiel werden wir eine Applikation automatisiert hoch- und runterskalieren, je nachdem unter wie viel Last die Applikation steht. Dazu verwenden wir eine Ruby Example Webapp.

Erstellen Sie daher ein neues Projekt mit dem Namen `[USERNAME]-autoscale`:

<details><summary>Tipp</summary>oc new-project [USERNAME]-autoscale</details><br/>

Auf dem Branch load gibt es einen CPU intensiven Endpunkt, welchen wir für unsere Tests verwenden werden. Dafür starten wir die App auf diesem Branch:

```bash
oc new-app openshift/ruby:2.5~https://github.com/chrira/ruby-ex.git#load --as-deployment-config
oc create route edge --insecure-policy=Redirect --service=ruby-ex
```

Warten sie bis die Applikation gebaut und ready ist und erste Metriken auftauchen (siehe Web Console -> Monitoring). Sie können dem Build wie auch den vorhandenden Pods folgen.

Bis die ersten Metriken auftauchen dauert es eine Weile, erst dann wird der Autoscaler richtig arbeiten können.

Nun definieren wir ein Set an Limiten für unsere Applikation, die für einen einzelnen Pod Gültigkeit hat.
Dazu editieren wir die `ruby-ex` DeploymentConfig:

<details><summary>Tipp</summary>oc edit dc ruby-ex</details><br/>

Folgende Resource Limits fügen wir dem Container hinzu:

```yaml
resources:
  limits:
    cpu: "0.2"
    memory: "256Mi"
```

Die Ressourcen sind ursprünglich leer: `resources: {}`. Achtung die `resources` müssen auf dem Container und nicht dem Deployment definiert werden.

Dies wird unser Deployment neu ausrollen und die Limiten enforcen.

Sobald unser neuer Container läuft können wir nun den Autoscaler konfigurieren:

Befehl mit Bestätigung:

```bash
$ oc autoscale dc ruby-ex --min 1 --max 3 --cpu-percent=25
horizontalpodautoscaler.autoscaling/ruby-ex autoscaled
```

In der Web Console ist ersichtlich, dass das manuelle Skalieren der Pods nicht mehr möglich ist. Dafür sind dort die Werte des Autoscaler ersichtlich.

Nun können wir auf dem Service Last erzeugen.

Ersetzen Sie dafür `[HOSTNAME]` mit Ihrer definierten Route:

<details><summary>Hostname abfragen</summary>oc get route -o custom-columns=NAME:.metadata.name,HOSTNAME:.spec.host</details><br/>

```bash
for i in {1..500}; do curl --insecure -s https://[HOSTNAME]/load ; done;
```

Jede Anfrage and den Load-Endpunkt sollte mit `Extensive task done` beantwortet werden.

Die aktuellen Werte holen wir über:

```bash
oc get horizontalpodautoscaler.autoscaling/ruby-ex
```

Folgendermassen können wir Statusänderungen unserer Pods folgen:

```bash
oc get pods -w
```

Sobald wir die Last beenden wird die Anzahl Pods nach einer gewissen Zeit automatisch wieder verkleinert. Die Kapazität wird jedoch eine Weile vorenthalten.

## Zusatzfrage

Es gibt auch einen `oc idle` Befehl. Was macht der?

## Zusatzübung für Schnelle

Zum Troubleshooting von Container ohne installierte Debugging Tools wurde die [k8s-debugbox](https://github.com/puzzle/k8s-debugbox) entwickelt.

Zuerst versuchen wir das Debugging mit dem oc Tool.

### Projekt erstellen

Erstellen Sie zunächst ein Projekt mit dem Namen "[USERNAME]-debugbox".

<details><summary>Befehl zum Erstellen eines Projekts</summary>oc new-project [USERNAME]-debugbox</details><br/>

### Test Applikation deployen

Zum Testen eignet sich ein minimales Container Image, wie z.B. eine Go Applikation in einem leeren Dateisystem (From scratch): [s3manager](https://hub.docker.com/r/mastertinner/s3manager)

Von diesem Image eine neue Applikation erstellen:

* Image: mastertinner/s3manager
* Environment:
  * ACCESS_KEY_ID=irgendoeppis
  * SECRET_ACCESS_KEY=x

<details><summary>Befehl zum Erstellen der Applikation</summary>oc new-app -e ACCESS_KEY_ID=irgendoeppis -e SECRET_ACCESS_KEY=x mastertinner/s3manager --as-deployment-config</details><br/>

### Debugging mit oc Tool

Versuchen Sie eine Remote-Shell im Container zu öffnen:

```bash
oc rsh dc/s3manager
```

Fehlermeldung:

```bash
ERRO[0000] exec failed: container_linux.go:349: starting container process caused "exec: \"/bin/sh\": stat /bin/sh: no such file or directory"
exec failed: container_linux.go:349: starting container process caused "exec: \"/bin/sh\": stat /bin/sh: no such file or directory"
command terminated with exit code 1
```

Das hat nicht funktioniert, weil im Container keine Shell vorhanden ist.

Können wir wenigstens das Environment ausgeben?

```bash
oc exec dc/s3manager env
```

Fehlermeldung:

```bash
time="2020-04-27T06:25:13Z" level=error msg="exec failed: container_linux.go:349: starting container process caused \"exec: \\\"env\\\": executable file not found in $PATH\""
exec failed: container_linux.go:349: starting container process caused "exec: \"env\": executable file not found in $PATH"
command terminated with exit code 1
```

Auch das geht nicht, der env Befehl steht nicht zur Verfügung.

Auch wenn wir versuchen das Terminal in der Web Console zu öffnen, bekommen wir einen Fehler.

Mit den Bordmitteln von OpenShift können wir diesen Container nicht debuggen. Dafür gibt es die [k8s-debugbox](https://github.com/puzzle/k8s-debugbox).

### Debugbox installieren

Installieren Sie die [k8s-debugbox](https://github.com/puzzle/k8s-debugbox) anhand der Anleitung: <https://github.com/puzzle/k8s-debugbox>.

### Debugbox anwenden

Über den Hilfeparameter die Möglichkeiten anzeigen lassen.

Befehl mit Ausgabe:

```bash
$ k8s-debugbox -h
Debug pods based on minimal images.

Examples:
  # Open debugging shell for the first container of the specified pod,
  # install debugging tools into the container if they aren't installed yet.
  k8s-debugbox pod hello-42-dmj88

...

Options:
  -n, --namespace='': Namespace which contains the pod to debug, defaults to the namespace of the current kubectl context
  -c, --container='': Container name to open shell for, defaults to first container in pod
  -i, --image='puzzle/k8s-debugbox': Docker image for installation of debugging via controller. Must be built from 'puzzle/k8s-debugbox' repository.
  -h, --help: Show this help message
      --add: Install debugging tools into specified resource
      --remove: Remove debugging tools from specified resource

Usage:
  k8s-debugbox TYPE NAME [options]
```

Wir wenden die Debugbox am s3manager Pod an:

<details><summary>Tipp für Pod Suche</summary>oc get pods</details><br/>

```bash
$ k8s-debugbox pod s3manager-1-jw4sl
Uploading debugging tools into pod s3manager-1-hnb6x
time="2020-04-27T06:26:44Z" level=error msg="exec failed: container_linux.go:349: starting container process caused \"exec: \\\"tar\\\": executable file not found in $PATH\""
exec failed: container_linux.go:349: starting container process caused "exec: \"tar\": executable file not found in $PATH"
command terminated with exit code 1

Couldn't upload debugging tools!
Instead you can patch the controller (deployment, deploymentconfig, daemonset, ...) to use an init container with debugging tools, this requires a new deployment though!
```

Auch dieser Versuch schlägt fehl, da die Tools ohne tar nicht in den Container kopiert werden können. Wir haben jedoch von der Debugbox die Information herhalten, dass wir die Installation über das Deployment machen sollen. Dabei wird die DeploymentConfiguration mit einem Init-Container erweitert. Der Init-Container kopiert die Tools in ein Volume, welches danach vom s3manager Container verwendet werden kann.

Patching der DeploymentConfiguration:

```bash
k8s-debugbox dc s3manager
```

Hier der Init-Container Auszug aus der gepatchten DeploymentConfiguration:

```yaml
spec:
  template:
    spec:
      initContainers:
      - image: puzzle/k8s-debugbox
        name: k8s-debugbox
        volumeMounts:
        - mountPath: /tmp/box
          name: k8s-debugbox
```

Nach einem erneuten Deployment des Pods befinden wir uns in einer Shell im Container. Darin stehen uns eine Vielzahl von Tools zur Verfügung. Jetzt können wir das Debugging durchführen.

Wo befinden sich die Debugging Tools?

<details><summary>Lösung</summary>/tmp/box/bin/</details><br/>

**Tipp** Mit der Eingabe von `exit` beenden wir die Debugbox.

Wie können wir die Änderungen an der DeploymentConfiguration rückgängig machen?

<details><summary>Lösung</summary>k8s-debugbox dc s3manager --remove</details><br/>
