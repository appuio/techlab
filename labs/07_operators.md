# Lab 7: Operators

Operators sind eine Art und Weise wie man Kubernetes-native Applikationen paketieren, deployen und verwalten kann. Kubernetes-native Applikationen sind Applikationen, die einerseits in Kubernetes/OpenShift deployed sind und andererseits auch über das Kubernetes/OpenShift-API (kubectl/oc) verwaltet werden. Seit OpenShift 4 verwendet auch OpenShift selber eine Reihe von Operators um den OpenShift-Cluster, also sich selber, zu verwalten.


## Einführung / Begriffe

Um zu verstehen, was ein Operator ist und wie er funktioniert, schauen wir zunächst den sogenannten Controller an, da Operators auf dessen Konzept basieren.


### Controller

Ein Controller besteht aus einem Loop, in welchem immer wieder der gewünschte Zustand (_desired state_) und der aktuelle Zustand (_actual state/obseved state_) des Clusters gelesen werden. Wenn der aktuelle Zustand nicht dem gewünschten Zustand entspricht, versucht der Controller den gewünschten Zustand herzustellen. Der gewünschte Zustand wird mit Ressourcen (Deployments, ReplicaSets, Pods, Services, etc.) beschrieben.

Die ganze Funktionsweise von OpenShift/Kubernetes basiert auf diesem Muster. Auf dem Master (controller-manager) laufen eine Vielzahl von Controllern, welche aufgrund von Ressourcen (ReplicaSets, Pods, Services, etc.) den gewünschten Zustand herstellen. Erstellt man z.B. ein ReplicaSet, sieht dies der ReplicaSet-Controller und erstellt als Folge die entsprechende Anzahl von Pods.

__Optional__: Der Artikel [The Mechanics of Kubernetes](https://medium.com/@dominik.tornow/the-mechanics-of-kubernetes-ac8112eaa302) gibt einen tiefen Einblick in die Funktionsweise von Kubernetes. In der Grafik im Abschnitt _Cascading Commands_ wird schön aufgezeigt, dass vom Erstellen eines Deployments bis zum effektiven Starten der Pods vier verschiedene Controller involviert sind.


### Operator

Ein Operator ist ein Controller, welcher dafür zuständig ist, eine Applikation zu installieren und zu verwalten. Ein Operator hat also applikations-spezifisches Wissen. Dies ist insbesondere bei komplexeren Applikationen nützlich, welche aus verschiedenen Komponenten bestehen oder zusätzlichen Administrationsaufwand erfordern (z.B. neu gestartete Pods müssen zu einem Applikations-Cluster hinzugefügt werden, etc.).

Auch für den Operator muss der gewünschte Zustand durch eine Ressource abgebildet werden. Dazu gibt es sogenannte Custom Resource Definitions (CRD). Mit CRDs kann man in OpenShift/Kubernetes beliebige neue Ressourcen definieren. Der Operator schaut dann konstant (_watch_), ob Custom Resources verändert werden, für welche der Operator zuständig ist und führt entsprechend der Zielvorgabge in der Custom Resource Aktionen aus.

Operators erleichtern es also komplexere Applikationen zu betreiben, da das Management vom Operator übernommen wird. Allfällige komplexe Konfigurationen werden durch Custom Resources abstrahiert und Betriebsaufgaben wie Backups oder das Rotieren von Zertifikaten etc. können auch vom Operator ausgeführt werden.


## Installation eines Operators

Ein Operator läuft wie eine normale Applikation als Pod im Cluster. Zur Installation eines Operators gehören in der Regel die folgenden Ressourcen:

* ***Custom Resource Definition***: Damit die neuen Custom Resources angelegt werden können, welche der Operator behandelt, müssen die entsprechenden CRDs installiert werden.
* ***Service Account***: Ein Service Account mit welchem der Operator läuft.
* ***Role und RoleBinding***: Mit einer Role definiert man alle Rechte, welche der Operator braucht. Dazu gehören mindestens Rechte auf die eigene Custom Resource. Mit einem RoleBinding wird die neue Role dem Service Account des Operators zugewiesen.
* ***Deployment***: Ein Deployment um den eigentlichen Operator laufen zu lassen. Der Operator läuft meistens nur einmal (Replicas auf 1 eingestellt), da sich sonst die verschiedenen Operator-Instanzen gegenseitig in die Quere kommen würden.

Auf OpenShift 4 ist standardmässig der Operator Lifecycle Manager (OLM) installiert. OLM vereinfacht die Installation von Operators. Der OLM erlaubt es uns, aus einem Katalog einen Operator auszuwählen (_subscriben_), welcher dann automatisch installiert und je nach Einstellung auch automatisch upgedated wird.

Als Beispiel installieren wir in den nächsten Schritten den ETCD-Operator. Normalerweise ist das Aufsetzen eines ETCD-Clusters ein Prozess mit einigen Schritten und man muss viele Optionen zum Starten der einzelnen Cluster-Member kennen. Der ETCD-Operator erlaubt es uns mit der EtcdCluster-Custom-Resource ganz einfach einen ETCD-Cluster aufzusetzen. Dabei brauchen wir kein detailliertes Wissen über ETCD, welches normalerweise für das Setup notwendig wäre, da dies alles vom Operator übernommen wird.
Wie für ETCD gibt es auch für viele andere Applikationen vorgefertigte Operators, welche einem den Betrieb von diesen massiv vereinfachen.


### Aufgabe 1: ETCD-Operator installieren

Zunächst legen wir ein neues Projekt an:

```
oc new-project [USERNAME]-operator-test
```

Wir schauen nun als erstes, welche Operators verfügbar sind. Unter den verfügbaren Operators finden wir den Operator `etcd` im Katalog Community Operators:

```
oc -n openshift-marketplace get packagemanifests.packages.operators.coreos.com | grep etcd
```

***Hinweis***: Als Cluster-Administrator kann man dies über die WebConsole machen (Operators -> OperatorHub).

Den ETCD-Operator können wir nun installieren, in dem wir eine Subscription anlegen. Mit vorhandenem `cat`-Binary kann dies mit folgendem Befehl gemacht werden, alternativ kann der Inhalt in ein File geschrieben und mit `oc create -f <Filename>` erstellt werden.

```
cat <<EOF | oc create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: etcd
spec:
  channel: singlenamespace-alpha
  installPlanApproval: Automatic
  name: etcd
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF
```

Mit der Subscription teilen wir dem Operator Lifecycle Manager mit, welchen Operator (`name`) von welchem Katalog (`source` und `sourceNamespace`) wir gerne installieren möchten. Die meisten Operators bieten verschiedene Update Channels (`channel`), wie z.B. alpha, beta oder stable an. OLM installiert dann die neueste Version (ClusterServiceVersion) vom gewählten Channel. Mit der Option `installPlanApproval` kann man zudem einstellen, dass OLM automatisch (`Automatic`) den entsprechenden Operator updated, wenn eine neue Version auf dem Update Channel verfügbar ist.

Im Rest der Aufgabe 1 wollen wir nun untersuchen, ob die Installation erfolgreich war und was uns der OLM auf Grund der Subscription alles erstellt hat.

Für die eigntliche Installation sucht OLM die neuste ClusterServiceVersion des `singlenamespace-alpha` Channels und legt diese an:

```
$ oc get csv
NAME                  DISPLAY   VERSION   REPLACES              PHASE
etcdoperator.v0.9.4   etcd      0.9.4     etcdoperator.v0.9.2   Succeeded
```

Die CSV löst die eigentliche Installation des Operators aus und wir sollten das Deployment des Operators im Projekt sehen:

```
$ oc get deployment
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
etcd-operator   1/1     1            1           5m
```

Weiter finden wir einen Service Account für das Deployment und eine Role inkl. RoleBinding:

```
$ oc get serviceaccounts
NAME            SECRETS   AGE
...
etcd-operator   2         5m
```

```
$ oc get role
NAME                        AGE
etcdoperator.v0.9.4-gdmm2   5m
```

```
$ oc get rolebinding
NAME                                            AGE
etcdoperator.v0.9.4-gdmm2-etcd-operator-7lhcd   5m
...
```

Im Hintergrund wurden zudem die neuen `CustomResourceDefinition`s angelegt:

* `etcdclusters.etcd.database.coreos.com` kind: `EtcdCluster`
* `etcdbackups.etcd.database.coreos.com` kind: `EtcdBackup`
* `etcdrestores.etcd.database.coreos.com` kind: `EtcdRestore`

Diese ermöglichen es uns in der nächsten Aufgabe, die CustomResource `EtcdCluster` anzulegen.

***Hinweis***: Um CRDs zu sehen, muss man Cluster-Administrator sein. Dann würde man die neuen CRDs wie folgt finden: `oc get crd | grep etcd`


### Aufgabe 2: ETCD-Cluster erstellen

Wir werden nun eine EtcdCluster-Resource anlegen, um einen ETCD-Cluster zu starten:

```
cat <<EOF | oc create -f -
apiVersion: etcd.database.coreos.com/v1beta2
kind: EtcdCluster
metadata:
  name: example
spec:
  size: 3
  version: 3.2.13
EOF
```

Nun können wir beobachten, dass drei Pods für den ETCD-Cluster erstellt werden/wurden:

```
$ oc get pod
NAME                             READY   STATUS    RESTARTS   AGE
etcd-operator-68c8484dc9-7sjfp   3/3     Running   0          27m
example-5fx5jxdh88               1/1     Running   1          7m22s
example-745pfjx2zt               1/1     Running   1          6m58s
example-g7856rl884               1/1     Running   1          8m2s
```

Wir können nun einfach den ETCD-Cluster über die EtcdCluster-Resource verändern.
Wir werden mit `oc edit` die Cluser-Size (.spec.size) auf 5 erhöhen, also den ETCD-Cluster hochskalieren.

```
oc edit etcdcluster example
# update .spec.size to 5
```

Wir können nun ebenfalls wieder mit `oc get pod` beobachten, dass der EtcdCluster korrekt hochskaliert wird.
Hierbei startet der ETCD-Operator nicht nur die Pods, sondern er fügt diese auch dem ETCD-Cluster als neue Members hinzu und stellt so sicher, dass die Daten auf die neuen Pods repliziert werden.
Dies können wir überprüfen, in dem wir uns in einem der ETCD-Pods die Cluster-Members auflisten lassen:

```
$ oc exec -it example-5fx5jxdh88 -- etcdctl member list
28af3778d7511ab6: name=example-99x775lzzt peerURLs=http://example-99x775lzzt.example.my-operator-test.svc:2380 clientURLs=http://example-99x775lzzt.example.my-operator-test.svc:2379 isLeader=false
5790fb58180b6680: name=example-g7856rl884 peerURLs=http://example-g7856rl884.example.my-operator-test.svc:2380 clientURLs=http://example-g7856rl884.example.my-operator-test.svc:2379 isLeader=false
92938f3e19f8df55: name=example-hxbcsxkjgw peerURLs=http://example-hxbcsxkjgw.example.my-operator-test.svc:2380 clientURLs=http://example-hxbcsxkjgw.example.my-operator-test.svc:2379 isLeader=false
9b4493c0eb24f65a: name=example-745pfjx2zt peerURLs=http://example-745pfjx2zt.example.my-operator-test.svc:2380 clientURLs=http://example-745pfjx2zt.example.my-operator-test.svc:2379 isLeader=false
e514d358ce1b7704: name=example-5fx5jxdh88 peerURLs=http://example-5fx5jxdh88.example.my-operator-test.svc:2380 clientURLs=http://example-5fx5jxdh88.example.my-operator-test.svc:2379 isLeader=true
```


### Aufgabe 3: ETCD-Cluster entfernen

Um den ETCD-Cluster zu entfernen, müssen wir lediglich die EtcdCluster Resource entfernen:

```
oc delete etcdcluster example
```


### Aufgabe 4: Operator deinstallieren

Um einen Operator zu deinstallieren, muss einerseits die Subscription und andererseits die sogenannte ClusterServiceVersion des Operators entfernt werden.

Mit dem Löschen der Subscription stellen wir sicher, dass keine neue Version mehr installiert wird:

```
oc delete sub etcd
```

Um die eigentlich installierte Version zu entfernen, muss die entsprechende ClusterServiceVersion deinstalliert werden.
Dazu finden wir zuerst die installierte ClusterServiceVersion:

```
$ oc get csv
NAME                  DISPLAY   VERSION   REPLACES              PHASE
etcdoperator.v0.9.4   etcd      0.9.4     etcdoperator.v0.9.2   Succeeded
```

Danach entfernen wir die ClusterServiceVersion:

```
oc delete csv etcdoperator.v0.9.4
```

Mit `oc get pod` können wir nun verifizieren, dass der Operator Pod entfernt wurde.


## Weiterführende Informationen

* [OpenShift Dokumentation zu Operators](https://docs.openshift.com/container-platform/latest/operators/olm-what-operators-are.html)
* [Buch von O'Reilly über Operators](https://www.redhat.com/cms/managed-files/cl-oreilly-kubernetes-operators-ebook-f21452-202001-en_2.pdf)

---

__Ende Lab 7__

<p width="100px" align="right"><a href="08_troubleshooting_ops.md">Troubleshooting →</a></p>

[← zurück zur Übersicht](../README.md)
