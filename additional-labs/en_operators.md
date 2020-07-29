# Operators

Centrally we have the Operator Lifecycle Manager installed. It provides us various operators ready to be consumed within our project.

We will deploy a etcd-cluster and see what we can do.

## Subscription

To be able to consume an operator we will create a subscription within a project. This will enable the CRDs, as well as install the operator that watches our CRDs as well as the deployed clusters.

Create project:

```bash
oc new-project operator-userXY
```

Subscribe to the etcd operator, by creating a file called `etcd-subscription.yaml` with the following content:

```yaml
# etcd-subscription.yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  generateName: etcd-
  namespace: operator-userXY
  name: etcd
spec:
  source: rh-operators
  name: etcd
  startingCSV: etcdoperator.v0.9.2
  channel: alpha
```

Now subscribe using the file:


```bash
oc create -f etcd-subscription.yaml
``` 

```bash
oc get pods
```

You can also subscribe to the operator through the Console, though not all integration might be ready, due to being technical preview by default.

You can see the running operator:

```bash
oc get pods
```

Once this is done, you are able to deploy a cluster, by using a crd.

You can do this by creating a file called `etcd-cluster.yaml` with the following content:

```yaml
# etcd-cluster.yaml
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdCluster"
metadata:
  name: "example-etcd-cluster"
spec:
  size: 3
  version: "3.1.10"
```

```bash
oc create -f etcd-cluster.yaml
```

Your cluster will be bootstrapped and will become ready:

```bash
oc get pods -w
oc get service
```

Describing the configured CRD gives us more information about the deployment:

```bash
oc describe EtcdCluster example-etcd-cluster
```

We can also store something within our cluster:

```bash
oc rsh example-etcd-cluster-XYZ
export ETCDCTL_API=3
etcdctl get foo
etcdctl put foo bar
etcdctl get foo
```

## Recovery

The operator is watching the deployed cluster and will recover it from failures. This is not a feature driven by a StatefulSet or a DeploymentConfig, rather the operator watches the deployed cluster and ensures it is kept in the desired overall state:

```bash
oc delete pod example-etcd-cluster-XYZ
oc get pods
oc rsh example-etcd-cluster-ABC
export ETCDCTL_API=3
etcdctl get foo
```

See how the changes got logged.

```bash
oc describe EtcdCluster example-etcd-cluster
```

## Updating

But well it looks like we didn't deploy a recent enough version:

```bash
oc describe pod -l app=etcd | grep -E 'Image:.*etcd' | uniq
    Image:         quay.io/coreos/etcd:v3.1.10
```

Let's update the cluster. This is done by patching the CRD to a new version

```bash
oc get EtcdCluster example-etcd-cluster -o yaml
# check the version
```

Now we can either edit the current deployment or supply an update to the spec:

```yaml
# etcd-update.yaml
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdCluster"
metadata:
  name: "example-etcd-cluster"
spec:
  size: 3
  version: "3.2.13"
```

```bash
oc apply -f etcd-update.yaml
```

Now watch how each member is being updated to 3.2.13 until all of them are updated:

```bash
oc describe EtcdCluster example-etcd-cluster
# watch the events of the resource or the overall events
oc get events
# in the end all images should be updated
oc describe pod -l app=etcd | grep -E 'Image:.*etcd' | uniq
    Image:         quay.io/coreos/etcd:v3.2.13
```

## Scale Up

Works exactly the same way:

```yaml
# etcd-scaleup.yaml
apiVersion: "etcd.database.coreos.com/v1beta2"
kind: "EtcdCluster"
metadata:
  name: "example-etcd-cluster"
spec:
  size: 5
  version: "3.2.13"
```

```bash
oc apply -f etcd-scaleup.yaml
oc get events -w
# until all are up
oc get pods -l app=etcd
```

## Scale Down

Is also supported with this operator. Do you figure out how?
