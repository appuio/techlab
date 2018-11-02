# OpenShift Development Environment

This Page will show you different possibilities, how to test self developed Docker containers or OpenShift templates and so on, whitout having access to a fully produvtiv OpenShift-plattform like for Example Appuio.

## Minishift

Minishift allows you to operate a locale OpenShift installation on your own Notebook in a VM with KVM, xhyve, Hyper-V or VirtualBox.

### Installation and Documentation

For the installation please follow the official Documentation: https://docs.openshift.org/latest/minishift/getting-started/installing.html

### Troubleshooting

#### DNS-Problems

Minishift uses nip.io (http://nip.io) for DNS-resolution. If the DNS-Server on your notebook can't resolve [private_ip_range].nip.io, you can use the DNS-Server of Quad 9 (9.9.9.9).

Infos Quad 9 DNS: https://www.quad9.net


## oc cluster up

Since the Version 1.3 of the OpenShift Client "oc" there is a possibility to start Openshift localy on your Laptop. This downloads a Dockercontainer which contains an OpenShift installation and starts it.

Prerequisites:
* oc 1.3+
* Docker 1.10

If all the prerequisits are met and docker is running, openshift can be started with:

```bash
oc cluster up
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

[← back to overview](../README.md)
