Create k8s cluster
kind create cluster --name cert-manager --image kindest/node:v1.31.2
kubectl get nodes

curl -LO https://github.com/cert-manager/cert-manager/releases/download/v1.12.14/cert-manager.yaml

Create k8s cluster
kind create cluster --name cert-manager --image kindest/node:v1.31.2
kubectl get nodes

Create cert manager

curl -LO https://github.com/cert-manager/cert-manager/releases/download/v1.12.14/cert-manager.yaml
mv cert-manager.yaml cert-manager-v1.12.14.yaml
kubectl create ns cert-manager
kubectl apply --validate=false -f cert-manager-v1.12.14.yaml 
kubectl get all -n cert-manager
kubectl get pods -n cert-manager

Create Ingress

kubectl -n ingress-nginx apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml
kubectl get all -n ingress-nginx
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

port forwarding to 80 and 443
kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 80
kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 443
curl -4 ifconfig.io

Create cluster issuer
kubectl apply -f cert-issuer-nginx-ingress.yaml
kubectl describe clusterissuer letsencrypt-cluster-issuer

Deploy an application for testing
kubectl apply -f deployment.yaml
kubectl get pods

Deploy a svc
kubectl apply -f service.yaml
kubectl get svc
kubectl port-forward svc/example-service 5000:80
kubectl apply -f certificate.yaml
kubectl describe certificate example-app
kubectl apply -f ingress.yaml

