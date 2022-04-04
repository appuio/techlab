# OpenShift Entwicklungsumgebung

Diese Seite zeigt verschiedene Möglichkeiten, wie selbst entwickelte Container oder OpenShift Templates etc. getestet werden können, ohne auf eine vollständige, produktive OpenShift-Plattform wie bspw. APPUiO Zugriff zu haben.

## CodeReady Containers

[CodeReady Containers](https://crc.dev/crc/) ermöglicht es, einen minimalen OpenShift 4 Cluster auf dem lokalen Computer laufen zu lassen.

## Minishift

[Minishift](https://docs.okd.io/3.11/minishift/index.html) erlaubt den Betrieb einer lokalen OpenShift-Installation auf dem eigenen Notebook in einer VM mit KVM, Hyper-V oder VirtualBox, __ermöglicht aber nur den Einsatz von OpenShift 3, nicht OpenShift 4__.
Minishift ist ursprünglich ein Fork von Minikube und verwendet [OKD](https://www.okd.io/), das Upstream-Projekt von OpenShift Container Platform.
Für den Einsatz von OCP 3 muss auf das Red Hat CDK ausgewichen werden.

## CDK

Das [Red Hat Container Development Kit](https://developers.redhat.com/products/cdk/overview) bietet sozusagen die "Enterprise"-Variante von Minishift an.
Anstelle von OKD kommt OCP zum Einsatz, weshalb eine Subscription benötigt wird, bspw. über das kostenlose [Red Hat Developer Program](https://developers.redhat.com/).

---

__Ende__

[← zurück zur Übersicht](../README.md)
