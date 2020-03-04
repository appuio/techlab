# Lab 2: OpenShift CLI installieren

In diesem Lab werden wir gemeinsam das CLI-Tool `odo` installieren und konfigurieren, damit wir danach die ersten Schritte auf der OpenShift Techlab Plattform durchführen können.

## `oc`

Der __oc client__ stellt ein Interface zu OpenShift bereit.

### Installation

Analog der [offiziellen Dokumentation](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_cli/getting-started-cli.html#cli-installing-cli_cli-developer-commands) kann der __oc client__ von der __Infrastructure Provider__ Seite heruntergeladen werden.

__Tipp__:
Alternativ kann die Binary auch direkt mittels folgenden Befehlen im Terminal installiert werden:

```bash
curl -fsSL https://mirror.openshift.com/pub/openshift-v4/clients/oc/4.2/linux/oc.tar.gz | sudo tar xfz - -C /usr/bin
```

### bash Command Completion (optional)

Dieser Schritt ist optional und funktioniert nicht auf Windows. Damit Command Completion auf macOS funktioniert, muss bspw. via `brew` das Paket `bash-completion` installiert werden.

`oc` bietet eine Command Completion, die gem. [Dokumention](https://docs.openshift.com/container-platform/4.2/cli_reference/openshift_cli/configuring-cli.html#cli-enabling-tab-completion_cli-configuring-cli) eingerichtet werden kann.

__Tipp__:
Alternativ kann die Bash Command Completion auch mittels folgenden Befehlen im Terminal installiert werden:

```
oc completion bash | sudo tee /etc/bash_completion.d/oc_bash_completion
```

__Ende Lab 2__

<p width="100px" align="right"><a href="03_first_steps.md">Erste Schritte auf der Lab Plattform →</a></p>

[← zurück zur Übersicht](../README.md)
