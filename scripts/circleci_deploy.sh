#!/usr/bin/env sh

set -e -u -o pipefail

# example usage
# ./scripts/circleci_deploy.sh test dev KUBE_TOKEN_TEST_DEV
# ./scripts/circleci_deploy.sh test staging KUBE_TOKEN_TEST_STAGING

environment_name=$1
deployment_name=$2
kube_token=$3

echo "kubectl configure credentials"
kubectl config set-credentials "circleci_${environment_name}_${deployment_name}" --token="${kube_token}"

echo "kubectl configure context"
kubectl config set-context "circleci_${environment_name}_${deployment_name}" --cluster="$KUBE_CLUSTER" --user="circleci_${environment_name}_${deployment_name}" --namespace="formbuilder-platform-${environment_name}-${deployment_name}"

echo "kubectl use circleci context"
kubectl config use-context "circleci_${environment_name}_${deployment_name}"

echo "apply kubernetes changes to ${environment_name} ${deployment_name}"
./scripts/deploy_platform.sh -p $environment_name -d $deployment_name

echo "delete pods in ${environment_name} ${deployment_name}"
./scripts/restart_platform_pods.sh -p $environment_name -d $deployment_name -c "circleci_${environment_name}_${deployment_name}"
