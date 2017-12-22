# OpenShift Entwicklungsumgebung

Diese Seite zeigt verschiedene Möglichkeiten, wie selbst entwickelte Docker Container oder OpenShift Templates etc. getestet werden können, ohne auf eine vollständige, produktive OpenShift-Plattform wie bspw. APPUiO Zugriff zu haben.

## Minishift

Minishift erlaubt den Betrieb einer lokalen OpenShift-Installation auf dem eigenen Notebook in einer VM mit KVM, xhyve, Hyper-V oder VirtualBox.

### Installation und Dokumentation

Für die Installation bitte der offiziellen Anleitung unter https://docs.openshift.org/latest/minishift/getting-started/installing.html folgen.


### Troubleshooting

#### DNS-Probleme

Minishift setzt bei der DNS-Auflösung auf nip.io (http://nip.io/). Wenn der auf dem eigenen Notebook konfigurierte DNS-Server [private_ip_range].nip.io nicht auflösen kann, kann z.B. der DNS-Server von Quad 9 (9.9.9.9) eingetragen werden.

Infos Quad 9 DNS: https://www.quad9.net


## oc cluster up

Seit Version 1.3 des OpenShift Clients "oc" existiert die Möglichkeit, ein OpenShift lokal auf dem eigenen Laptop zu starten. Hierfür wird ein Docker Container heruntergeladen, der eine OpenShift-Installation beinhaltet, und anschliessend gestartet.

Voraussetzungen:
* oc 1.3+
* Docker 1.10

Sind die Voraussetzung erfüllt und Docker gestartet, kann mit folgendem Befehl die OpenShift-Umgebung gestartet werden:
```
$ oc cluster up
```

### Dokumentation und Troubleshooting

#### iptables
Eine häufige Fehlerquelle ist die lokale Firewall. Docker verwendet iptables, um den Containern den Zugriff ins Internet zu gewährleisten. Es kann dabei vorkommen, dass sich bestimmte Rules in die Quere kommen. Häufig hilft ein Flushen der iptables Rulechains, nachdem die OpenShift-Instanz mit einem `oc cluster down` heruntergefahren wurde:
```
$ iptables -F
```
Anschliessend kann nochmals ein `oc cluster up` versucht werden.

#### Dokumentation

Die vollständige Dokumentation befindet sich unter https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md.

#### Ubuntu 16.04

Der Setup für Ubuntu 16.04 gestaltet sich ein wenig anders, als dies auf Fedora, CentOS oder RHEL der Fall ist, da der Registry Zugriff anders konfiguriert werden muss.

1. Docker installieren.
2. Docker Daemon für eine unsichere Docker Registry konfigurieren.
   - Dazu die Datei `/etc/docker/daemon.json` mit folgendem Inhalt erstellen:
     ```
     {
       "insecure-registries": ["172.30.0.0/16"]
     }
     ```

   - Nach dem Erstellen der Konfiguration den Docker Daemon neu starten.
     ```
     $ sudo systemctl restart docker
     ```

3. oc installieren

   Anleitung im Lab [OpenShift CLI installieren](labs/02_cli.md) befolgen.

4. Terminal öffnen und mit einem auf Docker berechtigten Benutzer diesen Befehl ausführen:
   ```
   $ oc cluster up
   ```

Cluster stoppen:
```
$ oc cluster down
```

## Vagrant

Mit dem [Puppet Modul für OpenShift 3](https://github.com/puzzle/puppet-openshift3/tree/dev) ist die Installation der Plattform in Vagrant automatisiert. Dieses Puppet Modul wird für die Installation und Aktualisierung produktiver Instanzen verwendet.

## Weitere Möglichkeiten

Ein [Blogpost von Red Hat](https://developers.redhat.com/blog/2016/10/11/four-creative-ways-to-create-an-openshiftkubernetes-dev-environment/) beschreibt neben `oc cluster up` noch weitere Varianten, wie eine lokale Entwicklungsumgebung aufgesetzt werden kann.

---

**Ende**

[← zurück zur Übersicht](../README.md)
