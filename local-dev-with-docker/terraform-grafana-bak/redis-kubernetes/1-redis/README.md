# 1) Create a namespace for Redis & Sentinel
kubectl create namespace redis-sentinel

# 2) Apply Redis ConfigMap to redis-sentinel namespace
kubectl apply -f redis-configmap.yaml -n redis-sentinel


# 3) Apply Redis StatefulSet and Service to redis-sentinel namespace
kubectl apply -f statefulset.yaml -n redis-sentinel
# List all Pods in the 'redis-sentinel' namespace
kubectl get pods -n redis-sentinel
kubectl describe pod redis-0 -n redis-sentinel 
kubectl logs redis-0 -n redis-sentinel -c redis

# Check if they are in 'Running' or 'Ready' state
# Then inspect logs for any suspicious errors:
kubectl logs <redis-pod-name> -n redis-sentinel

kubectl get svc -n redis-sentinel



# 4) Apply Sentinel StatefulSet and Service to redis-sentinel namespace
kubectl apply -f sentinel.yaml -n redis-sentinel
kubectl get pods -n redis-sentinel
kubectl logs <sentinel-pod-name> -n redis-sentinel



# 5) Add the Jetstack Helm repo (for cert-manager), then update
helm repo add jetstack https://charts.jetstack.io
helm repo update

# 6) Create the cert-manager namespace
kubectl create namespace cert-manager

# 7) Install cert-manager in the cert-manager namespace
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.12.0 \
  --set installCRDs=true

# 8) Create a Secret in cert-manager namespace for Route53 credentials
#    Replace <YOUR_SECRET_ACCESS_KEY> with your actual AWS secret key.
kubectl create secret generic route53-credentials-secret \
  --from-literal=secret-access-key="/Np1XZd/0ovuG5CHA0N/d0kdiciEdh+t3Km2AZ/D" \
  -n cert-manager

# 9) Apply your ClusterIssuer (cluster-scoped; no -n flag)
kubectl apply -f clusterissuer.yaml

# 10) Add and update the ingress-nginx repo
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# 11) Create an ingress-nginx namespace
kubectl create namespace ingress-nginx

# 12) Install the NGINX Ingress Controller with an AWS NLB
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.replicaCount=2 \
  --set controller.publishService.enabled=true \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb"

# 13) (Optional) Check the Service info for the ingress controller
kubectl get svc -n ingress-nginx
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx


# 14) Create your TCP ConfigMap in ingress-nginx namespace
kubectl apply -f tcp-services.yaml -n ingress-nginx
kubectl describe configmap tcp-services -n ingress-nginx

# Check NGINX Logs
kubectl logs <ingress-nginx-pod> -n ingress-nginx


# 15) Upgrade ingress-nginx Helm release to reference tcp-services
helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.replicaCount=2 \
  --set controller.publishService.enabled=true \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb" \
  --set controller.tcp.configMapName=tcp-services

  # Check the LoadBalancer DNS name:
  kubectl get svc ingress-nginx-controller -n ingress-nginx
  nslookup cert-test.therednosehomebuyers.com
  dig cert-test.therednosehomebuyers.com

# Test Redis Connection Externally
  redis-cli -h cert-test.therednosehomebuyers.com -p 6379 -a a-very-complex-password-here ping
  

 #  Verify cert-manager & Let’s Encrypt
 kubectl get pods -n cert-manager

 # Check the ClusterIssuer
 kubectl describe clusterissuer letsencrypt-dns

 # Create a Test Certificate
 kubectl apply -f test-certificate.yaml -n cert-manager
 kubectl describe certificate test-redis-certificate -n cert-manager





