# Test Plattform

Wo kann ich die Labs durchführen, wie komme ich an eine APPUiO oder OpenShift Container Plattform?

## Lokal
Seit der Version 1.3 vom OC Tool gibt es eine tolle Variante, ein OpenShift lokal zu starten. Einfach diesen Befehl eingeben:
```
$ oc cluster up
```
Damit dies funktioniert, muss Docker und das OC Tool installiert und konfiguriert sein.

### RHEL / Fedora / MacOS / Windows Setup
Offizielle Anleitung befolgen: https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md

### Ubuntu 16.04
Spezielle Anleitung für Ubuntu 16.04, da der Registry Zugriff anders konfiguriert werden muss.

| ACHTUNG |
| ------- |
| Manchmal funktioniert das Netzwerk für die Pods im Lokalen Cluster nicht. Als Abhilfe die iptables flushen mit dem Befehl `$ sudo iptables -F`, bevor der Cluster gestartet wird mit `oc cluster up`. |

1. Docker installieren.
2. Docker Daemon für eine unsichere Docker Registry konfigurieren.
   - Dazu die Datei `/etc/docker/daemon.json` mit folgendem Inhalt erstellen:
     ```
     {
       "insecure-registries": ["172.30.0.0/16"]
     }
     ```

   - Nach dem Erstellen der Konfiguration den Docker Deamon neu starten.
     ```
     $ sudo systemctl restart docker
     ```

3. OC Tool installieren

   Anleitung im Lab: [OpenShift CLI installieren](labs/02_cli.md)

4. Terminal öffnen und mit einem, für Docker berechtigten, Benutzer diesen Befehl ausführen:
   ```
   $ oc cluster up
   ```

Cluster Stoppen:
```
$ oc cluster down
```

---

**Ende **

[<< zurück zur Übersicht] (../README.md)
