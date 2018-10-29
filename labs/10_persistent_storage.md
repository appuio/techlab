# Lab 10: Persistent Storage and use for database

Data in a pod is not persistent, which is also the case in our example. If, for example, our MySQL pod disappears because of a change to the image, the existing data in the new pod will no longer exist. To prevent this, we are now attaching persistent storage to our MySQL pod.

## Task: LAB10.1

### Storage anfordern

Appending Persistent Storage is actually done in two steps. The first step involves the creation of a so-called PersistentVolumeClaim for our project. In the claim, we define, among other things, its name and size, so how much persistent memory we want to have at all.

However, the PersistentVolumeClaim represents the request, but not the resource itself. It is therefore automatically linked by OpenShift to a persistent volume available, with one with at least the requested size. If there are only larger persistent volumes, one of these volumes is used and the size of the claim is adapted. If there are only smaller Persistent volumes, the claim can not be linked and remains open until a volume of the appropriate size (or even larger) appears.

### Include volume in pod

In the second step, the previously created PVC is integrated into the correct pod. In  [LAB 6](06_scale.md) we edited the Deployment Config to insert the Readiness Probe. The same is true for the Persistent Volume. In contrast to [LAB 6](06_scale.md) we can expand the Deployment Config automatically with `oc volume`.

We will use the project from [LAB 8](08_database.md) `[USER]-dockerimage` again. **Hint:** `oc project [USER]-dockerimage`

The following command executes both the steps described at the same time, so it first creates the claim and then binds it as a volume in the pod:

```bash
$ oc volume dc/mysql --add --name=mysql-data --type persistentVolumeClaim \
     --claim-name=mysqlpvc --claim-size=256Mi --overwrite
```

**Note:** The modified Deployment Config will automatically deploy a new pod to OpenShift. This means, unfortunately, that the previously created DB schema and already inserted data have been lost.

Our application creates the DB schema at startup.

**Hint:** redeploy the application pod:

```
$ oc rollout latest example-spring-boot
```

With the command `oc get persistentvolumeclaim`, or something simple `oc get pvc`, we can now display the newly created PersistentVolumeClaim in the project:

```bash
$ oc get pvc
NAME       STATUS    VOLUME    CAPACITY   ACCESSMODES   AGE
mysqlpvc   Bound     pv34      256Mi      RWO,RWX       14s
```

The two status and volume attributes tell us that our claim was linked to Persistent Volume pv34.

With the following command, we can also check whether the volume has been integrated into the Deployment Config:

```bash
$ oc volume dc/mysql
deploymentconfigs/mysql
  pvc/mysqlpvc (allocated 256MiB) as mysql-data
```

## Task: LAB10.2: Persistence test

### Restore Data

Repeat [Lab-Task 8.4](08_database.md#l%C3%B6sung-lab84).

### Test

Now scale the mysql pod to 0 and then back to 1. Observe that the new pod is no longer losing the data.

---

**End Lab 10**

<p width="100px" align="right"><a href="11_template.md">Application templates →</a></p>

[← back to overview](../README.md)
