# Lab 2: OpenShift CLI installieren

In diesem Lab werden wir gemeinsam den oc Client installieren und konfigurieren, damit wir danach die ersten Schritte auf der OpenShift Techlab Plattform durchführen können.

## Command Line Interface

Der **oc client** stellt ein Interface zu OpenShift V3 bereit.

Der Client ist in Go programmiert und kommt als einzelnes Binary für die folgenden Betriebsysteme daher:

- Microsoft Windows
- macOS
- Linux

### Fedora

Fedora bietet via Repository das Paket `origin-clients`, welches bereits sämtliche hier beschriebenen Installationsschritte erledigt. Für die komplette Installation muss also lediglich folgender Befehl ausgeführt werden:
```
dnf install origin-clients
```
Für andere Betriebssysteme oder Linux-Distributionen müssen die im folgenden beschriebenen Schritte durchgeführt werden.


## oc Client herunterladen und installieren

Der oc Client wird vom [GitHub-Repository von OpenShift Origin](https://github.com/openshift/origin/releases/tag/v1.3.3) heruntergeladen:

* [Windows](https://github.com/openshift/origin/releases/download/v1.3.3/openshift-origin-client-tools-v1.3.3-bc17c1527938fa03b719e1a117d584442e3727b8-windows.zip)
* [Mac](https://github.com/openshift/origin/releases/download/v1.3.3/openshift-origin-client-tools-v1.3.3-bc17c1527938fa03b719e1a117d584442e3727b8-mac.zip)
* [Linux 64bit](https://github.com/openshift/origin/releases/download/v1.3.3/openshift-origin-client-tools-v1.3.3-bc17c1527938fa03b719e1a117d584442e3727b8-linux-64bit.tar.gz)
* [Linux 32bit](https://github.com/openshift/origin/releases/download/v1.3.3/openshift-origin-client-tools-v1.3.3-bc17c1527938fa03b719e1a117d584442e3727b8-linux-32bit.tar.gz)
* [CHECKSUM](https://github.com/openshift/origin/releases/download/v1.3.3/CHECKSUM)

Sobald der Client heruntergeladen wurde, muss er auf dem System in einem Verzeichnis, das über den **PATH** erreichbar ist, abgelegt werden.

**Linux**

```
~/bin
```

**macOS**

```
~/bin
```

**Windows**

```
C:\OpenShift\
```

## Korrekte Berechtigung auf Linux und macOS erteilen

Der oc Client muss ausgeführt werden können.

```
cd ~/bin
chmod +x oc
```

## den oc Client im PATH registrieren

Unter **Linux** und **macOS** ist das Verzeichnis ~/bin bereits im PATH, daher muss hier nichts gemacht werden.

Falls der oc Client in einem anderen Verzeichnis abgelegt wurde, kann der PATH wie folgt gesetzt werden:
```
$ export PATH=$PATH:[path to oc client]
```

### Windows

Unter Windows kann der PATH in den erweiterten Systemeinstellungen konfiguriert werden. Dies ist abhängig von der entsprechenden Windows Version:

- [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
- [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
- [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)

**Windows Quick Hack**

Legen sie den oc Client direkt im Verzeichnis *C:\Windows* ab.


## Installation verifizieren

Der oc Client sollte jetzt korrekt installiert sein. Am besten überprüfen wir das, indem wir den folgenden Command ausführen:
```
$ oc version
```
Der folgende Output sollte angezeigt werden:
```
oc v1.3.3
kubernetes v1.3.0+52492b4
```

Ist dies nicht der Fall, ist möglicherweise die PATH Variable nicht korrekt gesetzt.

---

## bash/zsh completion (optional)

Mit Linux und Mac kann die bash completion mit folgendem Befehl temporär eingerichtet werden:

```
source <(oc completion bash)
```

Oder für zsh:
```
source <(oc completion zsh)
```

---



<p width="100px" align="right"><a href="03_first_steps.md">Erste Schritte auf der Lab Plattform →</a></p>

[← zurück zur Übersicht](../README.md)
