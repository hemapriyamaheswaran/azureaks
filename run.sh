./terraform output kube_config > ~/.kube/aksconfig
export KUBECONFIG=~/.kube/aksconfig
kubectl apply -f deployment.yml
kubectl apply -f https://k8s.io/examples/pods/storage/pv-volume.yaml
kubectl apply -f https://k8s.io/examples/pods/storage/pv-claim.yaml
