# Lab 2: OpenShift CLI installieren

In diesem Lab werden wir gemeinsam den oc Client installieren und konfigurieren, damit wir danach die ersten Schritte auf der OpenShift Techlab Plattform durchführen können.

## Command Line Interface

Der **oc client** stellt ein Interface zu OpenShift V3 bereit.

der Client ist in Go programmiert und kommt als einzelnes Binary für die folgenden Betriebsysteme daher: 

- Microsoft Windows
- Mac OS X
- Linux


## oc Client herunterladen und installieren

Der oc Client kann direkt vom der APPUiO Beta Plattform herunter geladen werden:

* [Windows](https://master.appuio-beta.ch/console/extensions/clients/windows/oc.exe)
* [Mac OS X](https://master.appuio-beta.ch/console/extensions/clients/macosx/oc)
* [Linux](https://master.appuio-beta.ch/console/extensions/clients/linux/oc)

Sobald der Client heruntergeladen wurde, muss er auf dem System in einem Verzeichnis das über den **PATH** erreichbar ist abgelegt werden.
 
**Linux**
 
```
~/bin
```
 
**Mac OS X**
 
```
~/bin
```
 
**Windows**
 
```
C:\OpenShift\
```
 
## Korrekte Berechtigung Linux, Mac OS X

Der oc client muss ausgeführt werden können. 

```
cd ~/bin
chmod +x oc
```

## den oc Client im PATH registrieren

Unter **Linux** und **Mac OS X** ist das Verzeichnis ~/bin bereits im PATH, daher muss hier nichts gemacht werden. 

Falls der oc Client in einem anderen Verzeichnis abgelegt wurde, kann der PATH wie folgt gesetzt werden:
```
$ export PATH=$PATH:[path to oc client]
```

### Windows

Unter Windows kann der PATH in den Erweiterten Systemeinstellungen konfiguriert werden. Dies ist abhängig von der entsprechenden Windows Version:

- [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
- [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
- [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)

**Windwos Quick Hack**
```
Legen sie den oc client direkt im Verzeichnis C:\Windows ab
```

## Installation verifizieren

Der oc client sollte jetzt korrekt installiert sein, am besten überprüfen wir das in dem wir den folgenden Command ausführen:
```
$ oc version
```
Der folgende Output sollte angezeigt werden
```
oc v3.1.1.6-33-g81eabcc
kubernetes v1.1.0-origin-1107-g4c8e6f4
```

Ist dies nicht der Fall, ist möglicherweise die PATH Variable nicht korrekt gesetzt. 

---

## Erweiterte Bash Completion

Die Bash Completion kann für den oc Command installiert werden, laden Sie dafür das File von hier TODO Link herunter und installieren Sie es wie folgt:

```
sudo mv oc /etc/bash_completion.d/
sudo chown root: /etc/bash_completion.d/oc
sudo chmod g-w /etc/bash_completion.d/oc
```

---

**Ende Lab 2**

[<< zurück zur Übersicht] (../README.md)