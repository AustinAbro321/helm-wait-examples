#!/bin/bash
set -euo pipefail # fail if any of the waits fail
kubectl delete ns legacy --ignore-not-found=true
kubectl delete ns watcher --ignore-not-found=true
helm_path='../helm/bin/helm'

## basic example
$helm_path install basic-legacy basic/ --wait -n legacy --create-namespace
kubectl wait --for=condition=available deployment/basic-legacy-podinfo -n legacy --timeout=1s

$helm_path install basic-watcher basic/ --wait=watcher -n watcher --create-namespace
kubectl wait --for=condition=available deployment/basic-watcher-podinfo -n watcher --timeout=1s