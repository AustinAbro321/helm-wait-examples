#!/bin/bash
set -euo pipefail # fail if any of the waits fail
kubectl delete ns legacy --ignore-not-found=true
kubectl delete ns watcher --ignore-not-found=true
helm_path='../helm/bin/helm'

## basic example
$helm_path install basic-legacy basic/ --wait=legacy -n legacy --create-namespace
kubectl wait --for=condition=available deployment/basic-legacy-podinfo -n legacy --timeout=1s

$helm_path install basic-watcher basic/ --wait=watcher -n watcher --create-namespace
kubectl wait --for=condition=available deployment/basic-watcher-podinfo -n watcher --timeout=1s

# Ensure Helm waits for custom resources to be ready when using the watcher, but not when using the legacy wait
kubectl apply -f https://github.com/fluxcd/flux2/releases/download/v2.4.0/install.yaml
$helm_path install crs-watcher custom-resources/ --wait=legacy -n legacy --set targetNamespace=legacy --create-namespace
if kubectl get deployment podinfo -n legacy  > /dev/null 2>&1; then
  echo "Resource exists when it should not"
  exit 1
fi

# Default to watcher when no flag used
$helm_path install crs-watcher custom-resources/ --wait -n watcher --set targetNamespace=watcher --create-namespace
kubectl wait --for=condition=available deployment/podinfo -n watcher --timeout=1s

#kubectl wait --for=delete <resource>/<name> --timeout=60s