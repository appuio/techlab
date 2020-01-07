# Troubleshooting, was ist im Pod?

In diesen Labs werden wir Applikationen Troubleshooten.

## Aufgabe 1

Folgen Sie den Anweisungen im [Lab 7: Troubleshooting, was ist im Pod?](../labs/07_troubleshooting_ops.md).

## Aufgabe 2: Readyness check

In einer früheren Aufgabe haben wir für die Rolling update Strategie einen Readyness check auf einen /health eingerichtet.
Dieser Endpoint war über die Route nicht erreichbar. Wie kann der endpoint nun erreicht werden?

## Autoscaling

In diesem Beispiel werden wir eine Applikation automatisierte hoch und runter skalieren, je nach dem unter wieviel Last die Applikation steht. Dazu verwenden wir eine Ruby example webapp.

Erstellen Sie daher ein neues Projekt mit dem Namen `userXY-autoscale`:
<details><summary>Tipp</summary>oc new-project userXY-autoscale</details><br/>

Auf dem Branch load gibt es einen CPU intensiven Endpunkt, welchen wir für unsere Tests verwenden werden. Dafür starten wir die App auf diesem Branch:

```bash
oc new-app openshift/ruby:2.5~https://github.com/chrira/ruby-ex.git#load
oc create route edge --insecure-policy=Redirect --service=ruby-ex
```

Warten sie bis die Applikation gebaut und ready ist und erste Metriken auftauchen. Sie können dem Build, wie auch den vorhandenden Pods folgen.

Bis die ersten Metriken auftauchen dauert es eine Weile, erst dann wird der Autoscaler richtig arbeiten können.

Nun definieren wir ein Set an Limiten für unsere Applikation, die für einen einzelnen Pod gültigkeit haben.
Dazu editieren wir die `ruby-ex` DeploymentConfiguration:
<details><summary>Tipp</summary>oc edit dc ruby-ex</details><br/>

Folgende Resource Limiten fügen wir dem Container hinzu:

```yaml
        resources:
          limits:
            cpu: "0.2"
            memory: "256Mi"
```

Die Ressourcen sind ursprünglich leer: `resources: {}`. Achtung die `resources` müssen auf dem Container und nicht dem Deployment definiert werden.

Dies wird unser Deployment neu ausrollen und die Limiten enforcen.

Sobald unser neuer Container läuft können wir nun den autoscaler konfigurieren:

Befehl mit Bestätigung:

```bash
$ oc autoscale dc ruby-ex --min 1 --max 3 --cpu-percent=25
horizontalpodautoscaler.autoscaling/ruby-ex autoscaled
```

Nun können wir auf dem Service Last erzeugen.

Ersetzen Sie dafür `[route]` mit Ihrer definierten Route:
<details><summary>Tipp</summary>oc get route</details><br/>

```bash
for i in {1..500}; do curl --insecure -s https://[route]/load ; done;
```

Die aktuellen Werte holen wir über:

```bash
oc get horizontalpodautoscaler.autoscaling/ruby-ex
```

Folgendermassen können wir unseren pods folgen:

```bash
oc get pods -w
```

Sobald wir die Last beenden wird die Anzahl Pods nach einer gewissen Zeit automatisch wieder herunter skaliert. Die Kapazität wird jedoch eine Weile vorenthalten.
