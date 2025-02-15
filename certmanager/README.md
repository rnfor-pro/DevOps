Install ingress-nginx helm repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

Check versins
helm search repo ingress-nginx --versions

Install ingress-nginx manifest in your directory

#curl -LO https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
kubectl create ns ingress-nginx
kubectl -n ingress-nginx apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml
kubectl get all -n ingress-nginx

Create svc
kubectl apply -f service.yaml

Create ingress resource
kubectl apply -f ingress-userapi.yaml
kubectl -n ingress-nginx --address 0.0.0.0 port-forward svc/ingress-nginx-controller 80


