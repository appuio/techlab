# Lab 2: OpenShift CLI installieren

In diesem Lab werden wir gemeinsam den oc Client installieren und konfigurieren, damit wir danach die ersten Schritte auf der OpenShift Techlab Plattform durchführen können.

## Command Line Interface

Der **oc client** stellt ein Interface zu OpenShift bereit.

Der Client ist in Go programmiert und kommt als einzelnes Binary für die folgenden Betriebsysteme daher:

- Microsoft Windows
- Mac OS X
- Linux


## Auf Webinterface einloggen

Als erstes loggen wir auf der OpenShift Techlab Plattform ein. Die dazu benötigten Angaben werden vom Instruktor verteilt.


## oc Client herunterladen und installieren

Auf dem nun zu sehenden Webinterface oben rechts auf das Fragezeichen und anschliessend auf "Command Line Tools" klicken:

![cli](../images/lab_2_cli.png)

Nun erscheinen Links für den Download des Clients für die verschiedenen Betriebssysteme.

Sobald der Client heruntergeladen wurde, muss er auf dem System in einem Verzeichnis, das über den **PATH** erreichbar ist, abgelegt werden.

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

## Korrekte Berechtigung auf Linux und macOS erteilen

Der oc Client muss ausgeführt werden können.

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
oc v3.11.88
kubernetes v1.11.0+d4cacc0
features: Basic-Auth GSSAPI Kerberos SPNEGO
[...]
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

Damit die bash completion funktioniert, muss vorher das Paket `bash-completion` installiert werden.

Ubuntu:

```
sudo apt install bash-completion
```

Mac:

```bash
brew install bash-completion
source $(brew --prefix)/etc/bash_completion
```

Um die bash/zsh completion nicht nur temporär einzurichten kann man die oben erwähnte Zeile in die `.bash_profile` oder `.zshrc` einfügen.

---

**Ende Lab 2**

<p width="100px" align="right"><a href="03_first_steps.md">Erste Schritte auf der Lab Plattform →</a></p>

[← zurück zur Übersicht](../README.md)
