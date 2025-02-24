helm_path='../helm/bin/helm'
## basic example
kubectl delete ns legacy
kubectl delete ns watcher
$helm_path install basic-legacy basic/ --wait -n legacy --create-namespace
kubectl wait --for=condition=available deployment/basic-legacy-podinfo -n legacy --timeout=5s

$helm_path install basic-watcher basic/ --wait=legacy -n watcher --create-namespace
kubectl wait --for=condition=available deployment/basic-watcher-podinfo -n watcher --timeout=1s