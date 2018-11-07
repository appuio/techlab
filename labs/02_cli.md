# Lab 2: OpenShift CLI Installation

In this lab, we will install and configure the oc client so that we can then take the first steps on the OpenShift Techlab platform.

## Command Line Interface

The **oc client** provides an interface to OpenShift V3.

The client is programmed in Go and comes as a single binary for the following operating systems:

- Microsoft Windows
- macOS
- Linux

## Download oc and install client

The matching oc Client Version for this Techlab Version can be downloaded from the following URLs:

- [Linux](https://ose3-lab-master.puzzle.ch/console/extensions/clients/linux/oc)
- [Mac](https://ose3-lab-master.puzzle.ch/console/extensions/clients/macosx/oc)
- [Windows](https://ose3-lab-master.puzzle.ch/console/extensions/clients/windows/oc.exe)

Once the client has been downloaded, it must be placed on the system in a directory accessible via the **PATH** variable.

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

## Proper authorization on Linux and macOS

The oc Client must be an executable:

```
cd ~/bin
chmod +x oc
```

## register the oc client in the PATH variable

Under **Linux** and **macOS** the directory ~/bin is already in the PATH, so nothing has to be done here.

If the oc client has been placed in a different directory, the PATH can be set as follows:
```
$ export PATH=$PATH:[path to oc client]
```

### Windows

On Windows, the PATH can be configured in the advanced system settings. This is dependent on the corresponding Windows version:

- [Windows 7](http://geekswithblogs.net/renso/archive/2009/10/21/how-to-set-the-windows-path-in-windows-7.aspx)
- [Windows 8](http://www.itechtics.com/customize-windows-environment-variables/)
- [Windows 10](http://techmixx.de/windows-10-umgebungsvariablen-bearbeiten/)

**Windows Quick Hack**

Place the oc client directly in the directory *C:\Windows*.

## Verify the installation

The oc client should now be installed correctly. The best way to do this is to run the following command:

```
$ oc version
```

The following output should be displayed:

```
oc v3.5.5.31
kubernetes v1.5.2+43a9be4
[...]
```

If this is not the case, the PATH variable may not be set correctly.

---

## bash/zsh completion (optional)

With Linux and Mac, the bashcompletion can be temporarily set with the following command:

```
source <(oc completion bash)
```

Or for zsh:
```
source <(oc completion zsh)
```

To use bash completion the pakage `bash-completion` has to be installed.

Ubuntu:

```
sudo apt install bash-completion
```

---

**End of lab 2**

<p width="100px" align="right"><a href="03_first_steps.md">First Steps →</a></p>

[← back to overview](../README.md)
