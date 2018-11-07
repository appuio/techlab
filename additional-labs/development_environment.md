# OpenShift Development Environment

This page will show you different possibilities on how to test self-developed Docker containers or OpenShift templates and so on without having access to a fully productive OpenShift platform like APPUiO.

## Minishift

Minishift allows you to operate a local, virtualized OpenShift installation on your own machine using KVM, xhyve, Hyper-V or VirtualBox.

### Installation and Documentation

For the installation please follow [the official documentation](https://docs.openshift.org/latest/minishift/getting-started/installing.html).

### Troubleshooting

#### DNS-Problems

Minishift uses [nip.io](http://nip.io) for DNS resolution. If the DNS server on your machine can't resolve [private_ip_range].nip.io you can use another DNS service such as Quad 9 (`9.9.9.9`).

Infos Quad 9 DNS: https://www.quad9.net


## oc cluster up

As of `oc` release 1.3 there is a possibility to start OpenShift locally on your machine. This downloads a Docker container which contains an OpenShift installation and starts it.

Prerequisites:
* oc 1.3+
* Docker 1.10

If all the prerequisites are met and Docker is running, OpenShift can be started with:

```bash
oc cluster up
```

### Documentation und Troubleshooting

#### iptables
The local firewall often is a source for issues. Docker uses iptables to allow the containers access to the internet. There's the possibility that certain rules conflict with each other. Usually, a flush of the rule chain after stopping the OpenShift instance with `oc cluster down` helps:

```bash
iptables -F
```

Afterwards you can retry by using `oc cluster up`.

#### Documentation

You can find the complete documentation at <https://github.com/openshift/origin/blob/master/docs/cluster_up_down.md>.

#### Ubuntu 16.04

The setup for Ubuntu 16.04 is a little bit different as it is for Fedora, CentOS or RHEL, since the registry access has to be configured differently.

1. Install Docker
2. Add OpenShift's registry as an insecure registry by editing `/etc/docker/daemon.json` as follows:
     ```txt
     {
       "insecure-registries": ["172.30.0.0/16"]
     }
     ```

   - After editing/creating the file, restart docker.
     ```bash
     sudo systemctl restart docker
     ```

3. Install `oc`

   Follow the instructions in [lab 2 "Installing the OpenShift CLI](labs/02_cli.md)

4. Open the terminal and issue the command with a user that is authorized to use Docker:
   ```bash
   oc cluster up
   ```

Stopp the cluster:

```bash
oc cluster down
```

## Vagrant

With the [Puppet Modul for OpenShift 3](https://github.com/puzzle/puppet-openshift3/tree/dev) the installation with Vagrant is automated. This Puppet Modul is used for the installation and update of productive Clusters.

## Other Variants

The [Blogpost from Red Hat](https://developers.redhat.com/blog/2016/10/11/four-creative-ways-to-create-an-openshiftkubernetes-dev-environment/) describes other possibilities for a local development environment besides `oc cluster up`.

---

**End**

[← back to overview](../README.md)
