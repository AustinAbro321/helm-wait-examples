#!/bin/bash
set -euo pipefail # fail if any of the waits fail
kubectl delete ns legacy --ignore-not-found=true
kubectl delete ns watcher --ignore-not-found=true
helm_path='../helm/bin/helm'

#### ---  Basic Wait example ---- ####
echo "Testing basic wait examples"
$helm_path install basic-legacy basic/ --wait=legacy -n legacy --create-namespace
kubectl wait --for=condition=available deployment/basic-legacy-podinfo -n legacy --timeout=1s

$helm_path install basic-watcher basic/ --wait=watcher -n watcher --create-namespace
kubectl wait --for=condition=available deployment/basic-watcher-podinfo -n watcher --timeout=1s

#### ---  Helm Wait with custom resources ---- ####

echo "Testing custom resources wait examples"

# Helm waits for custom resources to be ready when using the watcher, but not when using the legacy wait
kubectl apply -f https://github.com/fluxcd/flux2/releases/download/v2.4.0/install.yaml

$helm_path install crs-legacy custom-resources/ --wait=legacy -n legacy --set targetNamespace=legacy --create-namespace
if kubectl get deployment podinfo -n legacy  > /dev/null 2>&1; then
  echo "Resource exists when it should not exist"
  exit 1
fi

# Default to watcher when no flag used
$helm_path install crs-watcher custom-resources/ --wait -n watcher --set targetNamespace=watcher --create-namespace
kubectl wait --for=condition=available deployment/podinfo -n watcher --timeout=1s


## ------ Helm job  Wait   ------- ####

echo "Testing Helm job wait examples"

# Without `--wait-for-jobs` the legacy waiter will do no waiting, the watcher will wait for the job to be "ready" which in this case is just created
$helm_path install job-legacy job/ --wait=legacy -n legacy --create-namespace --set jobName=no-wait-for-job
if kubectl wait --for=condition=complete job/no-wait-for-job -n legacy --timeout=1s; then
  echo "waited for job completion when we shouldn't"
  exit 1
fi
echo "^expecting error message since we did not use --wait-for-jobs"

$helm_path install job-watcher job/ --wait=watcher -n watcher --create-namespace --set jobName=wait-for-job-ready
kubectl wait --for=condition=Ready pod -l job-name=wait-for-job-ready -n watcher
if kubectl wait --for=condition=complete job/no-wait-for-job -n legacy --timeout=1s; then
  echo "waited for job completion when we shouldn't"
  exit 1
fi
echo "^expecting error message since we did not use --wait-for-jobs"

# Now with wait for jobs both should wait for the job to be complete
$helm_path install job-legacy-wait job/ --wait=legacy --wait-for-jobs -n legacy --create-namespace --set jobName=wait-for-job
kubectl wait --for=condition=complete job/wait-for-job -n legacy --timeout=1s

$helm_path install job-watcher-wait job/ --wait=watcher --wait-for-jobs -n watcher --create-namespace --set jobName=wait-for-job
kubectl wait --for=condition=complete job/wait-for-job -n watcher --timeout=1s

## ------ Helm Hook Wait   ------- ####

echo "Testing Helm hook wait examples"

# Hooks should wait even when there is no wait flag used / wait is false

$helm_path install watcher-hook hooks/ --wait=false -n watcher --create-namespace
kubectl wait --for=condition=complete job/watcher-hook -n watcher --timeout=1s

### ------ Helm Uninstall Wait   ------- ####

echo "testing uninstall"

$helm_path install delete-legacy wait_for_delete/ --wait=legacy -n legacy --create-namespace
$helm_path uninstall delete-legacy --wait=legacy -n legacy 
kubectl wait --for=delete pods/delete-legacy -n legacy --timeout=1s

$helm_path install delete-watcher wait_for_delete/ --wait=watcher -n watcher --create-namespace
$helm_path uninstall delete-watcher --wait=true -n watcher
kubectl wait --for=delete pod/delete-watcher -n watcher --timeout=1s

### ------ Helm Upgrade wait #####

echo "testing upgrade" 

$helm_path upgrade basic-legacy basic/ --wait=legacy -n legacy --set replicaCount=10
replicas=$(kubectl get deployment basic-legacy-podinfo -n legacy -o jsonpath='{.spec.replicas}')
if [ "$replicas" -ne 10 ]; then
  echo "Expected 10 replicas, but got $replicas"
  exit 1
fi

$helm_path upgrade basic-watcher basic/ --wait=watcher -n watcher --set replicaCount=10
replicas=$(kubectl get deployment basic-watcher-podinfo -n watcher -o jsonpath='{.spec.replicas}')
if [ "$replicas" -ne 10 ]; then
  echo "Expected 10 replicas, but got $replicas"
  exit 1
fi

$helm_path rollback basic-legacy --wait=legacy -n legacy
replicas=$(kubectl get deployment basic-legacy-podinfo -n legacy -o jsonpath='{.spec.replicas}')
if [ "$replicas" -ne 1 ]; then
  echo "Expected 1 replicas, but got $replicas"
  exit 1
fi

$helm_path rollback basic-watcher --wait -n watcher
replicas=$(kubectl get deployment basic-watcher-podinfo -n watcher -o jsonpath='{.spec.replicas}')
if [ "$replicas" -ne 1 ]; then
  echo "Expected 1 replicas, but got $replicas"
  exit 1
fi

# $helm_path upgrade basic-watcher basic/ --wait=watcher -n watcher --set replicaCount=10

echo "success!"