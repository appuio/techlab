Templating is key for application portability, be it portability between stages as in dev->preprod->prod or between different clusters. Creating reproducible and versioned deployments of Kubernetes applications is key to be being succsesful in the cloud world.


There are quite a few good solutions for templating out there, here are some very popular ones:

- Openshift templates: If you have an OpenShift cluster, this option comes with the cluster out of the box. See [openshift_templates.md](this) for further details.

- Kustomize: A very popular open-source project that lets you customize raw, template-free YAML files for multiple purposes, leaving the original YAML untouched and usable as is. See [https://github.com/kubernetes-sigs/kustomize](this) for details.

- Helm: [https://helm.sh/](Helm) is another very popular solution that enables easy deployment & management of many popular applications but it also allows users to create their own *Helm charts*.
