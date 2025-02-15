kubectl create ns cert-manager-test
kubectl apply -f ./selfsigned/issuer.yaml 
kubectl apply -f ./selfsigned/certificate.yaml
kubectl describe certificate -n cert-manager-test
kubectl get secrets -n cert-manager-test