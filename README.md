# Instructions

## Build and publish Docker images

1. Update operator versions in Makefile
1. `make bundle-build bundle-push`
1. `make catalog-build catalog-push`

## Create secrets

Change to project `openshift-operators`:

```
oc project openshift-operators
```

Create pull secret:

```
oc create secret generic addon-pullsecret --from-file=.dockerconfigjson=<path/to/.docker/config.json> --type=kubernetes.io/dockerconfigjson
```

Create config secret:

```
create-cluster-secret $(create-cluster test | jq -r '.id') addon-connectors-operator-parameters
```

This command expects you to have `cos-tools/bin` in your PATH.

## Create CatalogSource

```
oc apply -f catalog-source.yaml
```

## Install the operators

Open the OpenShift console and use the OperatorHub to install the cos-fleetshard-sync operator.
