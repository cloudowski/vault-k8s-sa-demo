#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

DEST=$(mktemp -d)

SA_NAME=$1
SA_TOKEN=$2
SA_NS=${3:-test}
KUBECONFIG_FILE=$DEST/kubeconfig

kubectl config view --minify=true --flatten -o json | jq '.clusters[0].cluster."certificate-authority-data"' -r | base64 --decode > $DEST/ca.crt
endpoint=`kubectl config view --minify -o jsonpath="{.clusters[0].cluster.server}"`

kubectl --kubeconfig=$KUBECONFIG_FILE config set-cluster $SA_NAME --embed-certs --server=$endpoint --certificate-authority=$DEST/ca.crt
kubectl --kubeconfig=$KUBECONFIG_FILE config set-credentials $SA_NAME --token=$SA_TOKEN
kubectl --kubeconfig=$KUBECONFIG_FILE config set-context $SA_NAME --cluster=$SA_NAME --user=$SA_NAME --namespace=$SA_NS
kubectl --kubeconfig=$KUBECONFIG_FILE config use-context $SA_NAME

rm $DEST/*.crt

cat <<EOF 


# KUBECONFIG available at $KUBECONFIG_FILE
# use it to access the cluster
KUBECONFIG=$KUBECONFIG_FILE kubectl get pod

EOF