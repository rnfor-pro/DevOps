
1. **Create Namespaces** (if not already created):

   ```bash
   kind create cluster --config cluster-config.yaml
   kubectl create namespace dev-redis
   kubectl create namespace ingress-nginx
   ```

2. **Deploy Redis**:

   ```bash
   helm install redis-cluster bitnami/redis -n dev-redis -f values.yaml
   ```

3. **Apply TCP Services ConfigMap**:

   ```bash
   kubectl apply -f tcp-services-configmap.yaml
   ```

4. **Deploy Nginx Ingress Controller**:

   - Using Helm:

     ```bash
     helm install ingress-nginx ingress-nginx/ingress-nginx \
       --namespace ingress-nginx \
       --set controller.extraArgs.tcp-services-configmap=ingress-nginx/tcp-services
     ```

   - Or apply the manual deployment:

     ```bash
     kubectl apply -f ingress-nginx-controller.yaml
     ```

5. **Apply Ingress Resource** (if using domain-based routing):

   ```bash
   kubectl apply -f ingress-redis.yaml
   ```

---

## Redis Endpoint for External Access

If `pmproxy` is running on a different cluster or VM, provide this endpoint:

```
redis://redis.your-domain.com:6379
```

This setup ensures Redis is accessible externally via the Nginx Ingress Controller with proper liveness and readiness probes configured.