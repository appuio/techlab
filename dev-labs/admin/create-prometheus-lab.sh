#!/bin/bash

wd=$(readlink -f $(dirname $0))

oc -n openshift-monitoring get configmap cluster-monitoring-config || oc -n openshift-monitoring create configmap cluster-monitoring-config

oc patch -n openshift-monitoring configmap/cluster-monitoring-config -p '{"data":{"config.yaml": "techPreviewUserWorkload:\n  enabled: true"}}'

oc get clusterrole monitor-crd-edit || oc create -f $wd/custom-metrics-role.yaml

for user in $(oc get users -o jsonpath='{ range .items[*]}{.metadata.name }{"\n"}' | grep -E '^user'); do
  oc new-project prometheus-${user}
  oc policy add-role-to-user admin "${user}"  -n "prometheus-${user}"
  oc adm policy add-role-to-user -n "prometheus-${user}" monitor-crd-edit "${user}"
done
