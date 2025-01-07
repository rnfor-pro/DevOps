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
  "5000": "redis/sentinel:5000"
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

# 8) In AWS, open ports 6379, 5000 (and 80, 443 if needed) 
#    on the security group attached to the 'ingress-nginx-controller' LB.

# 9) Create or update your Route53 DNS record so:
#    cert-test.therednosehomebuyers.com -> <LB-DNS-NAME> (alias)
#    Example with AWS CLI:

export HOSTED_ZONE_ID="Z04496012Q3COVDQNLP3M"
export LB_DNS_NAME="84f927b2fc7e4997a6d9a18d82f6cd0-879240765.us-west-2.elb.amazonaws.com"
export SUBDOMAIN="cert-test.therednosehomebuyers.com"

cat <<EOF > /tmp/route53-change-batch.json
{
  "Comment": "Create or update A alias record for $SUBDOMAIN",
  "Changes": [
    {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "$SUBDOMAIN",
        "Type": "A",
        "AliasTarget": {
          "HostedZoneId": "$HOSTED_ZONE_ID",
          "DNSName": "$LB_DNS_NAME",
          "EvaluateTargetHealth": false
        }
      }
    }
  ]
}
EOF

aws route53 change-resource-record-sets \
  --hosted-zone-id $HOSTED_ZONE_ID \
  --change-batch file:///tmp/route53-change-batch.json

# 10) Test external connectivity
#     (Make sure you have redis-cli installed externally)
redis-cli -h cert-test.therednosehomebuyers.com -p 6379 ping
redis-cli -h cert-test.therednosehomebuyers.com -p 6379 set foo bar
redis-cli -h cert-test.therednosehomebuyers.com -p 6379 get foo
redis-cli -h cert-test.therednosehomebuyers.com -p 5000 sentinel get-master-addr-by-name mymaster





