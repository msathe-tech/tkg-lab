#!/bin/bash -e

if [ ! $# -eq 1 ]; then
 echo "Must supply cluster name as args"
 exit 1
fi
CLUSTER_NAME=$1

TMC_ACME_FITNESS_WORKSPACE_NAME=$(yq r params.yaml acme-fitness.tmc-workspace)
VMWARE_ID=$(yq r params.yaml vmware-id)
IAAS=$(yq r params.yaml iaas)

mkdir -p generated/$CLUSTER_NAME/tmc
cp -r tmc/config/* generated/$CLUSTER_NAME/tmc/

# acme-fitness-dev.yaml
yq write -d0 generated/$CLUSTER_NAME/tmc/workspace/acme-fitness-dev.yaml -i "fullName.name" $TMC_ACME_FITNESS_WORKSPACE_NAME
yq write -d0 generated/$CLUSTER_NAME/tmc/workspace/acme-fitness-dev.yaml -i "objectMeta.labels.origin" $VMWARE_ID

# tkg-wlc-acme-fitness.yaml
yq write -d0 generated/$CLUSTER_NAME/tmc/namespace/tkg-wlc-acme-fitness.yaml -i "fullName.clusterName" $VMWARE_ID-$CLUSTER_NAME-$IAAS
yq write -d0 generated/$CLUSTER_NAME/tmc/namespace/tkg-wlc-acme-fitness.yaml -i "objectMeta.labels.origin" $VMWARE_ID
yq write -d0 generated/$CLUSTER_NAME/tmc/namespace/tkg-wlc-acme-fitness.yaml -i "spec.workspaceName" $TMC_ACME_FITNESS_WORKSPACE_NAME

tmc workspace create -f generated/$CLUSTER_NAME/tmc/workspace/acme-fitness-dev.yaml
tmc workspace iam add-binding $TMC_ACME_FITNESS_WORKSPACE_NAME --role workspace.edit --groups acme-fitness-devs
tmc cluster namespace create -f generated/$CLUSTER_NAME/tmc/namespace/tkg-wlc-acme-fitness.yaml
