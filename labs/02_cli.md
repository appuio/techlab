# Lab 2: OpenShift CLI installieren

In diesem Lab werden wir gemeinsam das CLI-Tool `odo` installieren und konfigurieren, damit wir danach die ersten Schritte auf der OpenShift Techlab Plattform durchführen können.

## `oc`

Der __oc client__ stellt ein Interface zu OpenShift bereit.

### Installation

Analog der [offiziellen Dokumentation](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_cli/getting-started-cli.html#cli-installing-cli_cli-developer-commands) kann der __oc client__ von der __Infrastructure Provider__ Seite heruntergeladen werden.

__Tipp__:
Alternativ kann die Binary auch direkt mittels folgenden Befehlen im Terminal installiert werden:

```
curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.2/linux/oc.tar.gz | sudo tar xfz - -C /usr/bin
```

### bash Command Completion (optional)

Dieser Schritt ist optional und funktioniert nicht auf Windows. Damit Command Completion auf macOS funktioniert, muss bspw. via `brew` das Paket `bash-completion` installiert werden.

`oc` bietet eine Command Completion, die gem. [Dokumention](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_cli/configuring-cli.html#cli-enabling-tab-completion_cli-configuring-cli) eingerichtet werden kann.

__Tipp__:
Alternativ kann die Bash Command Completion auch mittels folgenden Befehlen im Terminal installiert werden:

```
sudo oc completion bash > /etc/bash_completion.d/oc_bash_completion
```

## `odo`

Via `odo` kommunizieren wir mit OpenShift. Es wurde mit OpenShift 4 neu ins Leben gerufen und fokussiert sich auf die Entwickler-relevanten Aufgaben.

`odo` ist in [Go](https://github.com/openshift/odo) programmiert und kommt als einzelnes Binary für die gängigsten Betriebsysteme daher.

### Installation

Folgen Sie für die Installation der [offiziellen Installationsdokumentation](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_developer_cli/installing-odo.html).

Es sollte nun möglich sein, auf der Kommandozeile den Befehl `odo version` auszuführen und einen ähnlichen Output wie der folgende zu erhalten (die Versionsnummer kann unterschiedlich sein):

```
odo v1.0.2 (HEAD)
```

### bash/zsh Command Completion (optional)

Dieser Schritt ist optional und funktioniert nicht auf Windows. Damit Command Completion auf macOS funktioniert, muss bspw. via `brew` das Paket `bash-completion` installiert werden.

`odo` bietet eine Command Completion, die gem. [Dokumentation](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_developer_cli/configuring-the-odo-cli.html#using-command-completion_configuring-the-odo-cli) eingerichtet werden kann.

---

__Ende Lab 2__

<p width="100px" align="right"><a href="03_first_steps.md">Erste Schritte auf der Lab Plattform →</a></p>

[← zurück zur Übersicht](../README.md)
