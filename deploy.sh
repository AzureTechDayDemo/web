#!/bin/sh

set -e
# SP, PASSWORD , CLUSTER_NAME, CLUSTER_RESOURCE_GROUP
az configure --defaults acr=$RUN_REGISTRYNAME
mkdir /tmp

az login \
    --service-principal \
    --username $SP \
    --password $PASSWORD \
    --tenant $TENANT  > /dev/null

az aks get-credentials \
    -g $CLUSTER_RESOURCE_GROUP \
    -n $CLUSTER_NAME

echo -- helm init --client-only --
helm init --client-only # > /dev/null

echo -- az acr helm repo add --
az acr helm repo add

echo -- helm fetch --untar $RUN_REGISTRYNAME/importantThings --
helm fetch --untar $RUN_REGISTRYNAME/importantThings

echo -- helm upgrade web ./importantThings --
helm upgrade web ./importantThings \
    --reuse-values \
    --set web.image=$RUN_REGISTRY/demo42/web:$RUN_ID

# helm install demo42 ./importantThings -n web --set web.image=atddemos.azurecr.io/demo42/web:ccx

# helm upgrade web ./importantThings \
#     --reuse-values \
#     --set web.image=atddemos.azurecr.io/demo42/web:cc11
