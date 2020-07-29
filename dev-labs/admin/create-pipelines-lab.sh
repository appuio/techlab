#!/bin/bash

wd=$(readlink -f $(dirname $0))

for user in $(oc get users -o jsonpath='{ range .items[*]}{.metadata.name }{"\n"}' | grep -E '^user'); do
  ns_cicd="cicd-${user}"
  ns_dev="app-dev-${user}"
  ns_int="app-int-${user}"
  ns_prod="app-prod-${user}"

  oc new-project "$ns_cicd"
  oc new-project "$ns_dev"
  oc new-project "$ns_int"
  oc new-project "$ns_prod"

  oc policy add-role-to-user admin "${user}"  -n "$ns_cicd"
  oc policy add-role-to-user admin "${user}"  -n "$ns_dev"
  oc policy add-role-to-user admin "${user}"  -n "$ns_int"
  oc policy add-role-to-user admin "${user}"  -n "$ns_prod"

  oc process openshift//jenkins-persistent MEMORY_LIMIT=1024Mi DISABLE_ADMINISTRATIVE_MONITORS=true  VOLUME_CAPACITY=5Gi  | oc create -n $ns_cicd -f -
done
