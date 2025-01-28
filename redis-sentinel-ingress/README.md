# 1) Create the redis namespace
kubectl create namespace redis
kubectl get ns
kubectl apply -f redis-configmap.yaml
kubectl get configmaps -n redis

# 2) Deploy your Redis & Sentinel manifests:
kubectl apply -n redis -f redis-statefulset.yaml
kubectl get pods -n redis -w
kubectl apply -n redis -f sentinel-statefulset.yaml
kubectl get pods -n redis -w

# 3) Confirm Redis & Sentinel pods are running
kubectl get pods -n redis
kubectl get svc -n redis


# 4) Deploy the NGINX Ingress Controller via Helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  -f ingress-values.yaml

comfirm pods are running
kubectl get pods -n ingress-nginx

# 5) Create the TCP services ConfigMap for Redis & Sentinel
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: tcp-services
  namespace: ingress-nginx
data:
  "6379": "redis/redis:6379"
EOF

Comfirm service is created
kubectl get svc -n ingress-nginx
kubectl get configmap tcp-services -n ingress-nginx


# 6) Re-run Helm to set the --tcp-services-configmap argument
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.extraArgs.tcp-services-configmap="ingress-nginx/tcp-services"

Restart the ingress controller pods
kubectl rollout restart deployment ingress-nginx-controller -n ingress-nginx


# 7) Check that the load balancer has open ports 6379 and 5000
kubectl get svc -n ingress-nginx


# Troubleshooting
# Manually Patch the Ingress Controller Deployment (to open the container port)
```bash
kubectl patch deployment ingress-nginx-controller -n ingress-nginx \
  --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/ports/-","value":{"containerPort":6379,"name":"redis-tcp","protocol":"TCP"}}]'

```
# Verify
```bash
kubectl get deployment ingress-nginx-controller -n ingress-nginx -o yaml

```
# Manually Patch the Ingress Controller Service (to actually expose port 6379)
```bash
kubectl patch service ingress-nginx-controller -n ingress-nginx \
  --type=json \
  -p='[{"op":"add","path":"/spec/ports/-","value":{"name":"redis-tcp","port":6379,"targetPort":6379,"protocol":"TCP"}}]'

```

# Verify
```bash
kubectl get svc ingress-nginx-controller -n ingress-nginx -o yaml

```