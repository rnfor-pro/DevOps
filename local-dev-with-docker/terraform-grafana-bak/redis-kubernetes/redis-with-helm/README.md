[Redis sentinel HA on Kubernetes](https://stackoverflow.com/questions/67886898/redis-sentinel-ha-on-kubernetes)

First we need to get the values.yaml file from the Redis Helm Chart to customize our installation
[Redis Helm harts](https://github.com/bitnami/charts/tree/main/bitnami/redis)

To follow along make sure you have a k8s cluster.
I am using kind on mac for this et up.

- Create a K8s cluster
  - If you need a one node cluster
```bash
kind create cluster --name redis --image kindest/node:v1.31.2 
```
  - If you need a multi-node cluster
```bash
kind create cluster --config cluster-config.yaml
```  
- Verify
```bash
kubectl get nodes
```

Get the `values.yaml` file from the Redis Helm Chart to customize the installation
```bash
wget https://raw.githubusercontent.com/bitnami/charts/master/bitnami/redis/values.yaml
```

```bash
# values.yaml

global:
  redis:
    password: a-very-complex-password-here
...
replica:
  replicaCount: 3
...
sentinel:
  enabled: true
...
metrics:
  enabled: true  # Enable the metrics exporter
  serviceMonitor:
    enabled: true  # Create a ServiceMonitor for Prometheus Operator
  podMonitor:
    enabled: false  # Disable PodMonitor if not using it
  service:
    enabled: true
    annotations:
      prometheus.io/scrape: "true"  # Ensure Prometheus scrapes the metrics endpoint
      prometheus.io/port: "9121"    # Specify the metrics exporter port

```

Add the Bitnami Helm Chart repository
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Install the Chart
```bash
kubectl create namespace redis
helm install redis-sentinel bitnami/redis --values redis-values.yaml --namespace redis
kubectl get all -n redis
```
To connect to your database from outside the cluster execute the following commands:
```bash
    kubectl port-forward --namespace redis svc/redis-sentinel-master 6379:6379 &
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379
```

Importantly, we must ensure the sentinel is deployed alongside our Redis instance. To list the containers within all the pods, we can use the kubectl top pod –containers command
```bash
kubectl top pod --containers -n redis
```

- Check if the ServiceMonitor for Redis Sentinel is created
```bash
kubectl get servicemonitors -n redis
```

To get your password run
```bash
export REDIS_PASSWORD=$(kubectl get secret --namespace redis redis-sentinel -o jsonpath="{.data.redis-password}" | base64 -d)
echo $REDIS_PASSWORD
```


- Testing failover
```bash
kubectl get pods -n redis -o wide
kubectl delete pod redis-sentinel-master-0 -n redis 
kubectl logs redis-sentinel-master-0  -n redis
kubectl get pods -n redis -o wide
kubectl -n redis exec -it redis-sentinel-master-0 -- sh
redis-cli 
auth a-very-secure-password
info replication

Insert data

SET key1 "value1"
SET user:1:name "John Doe"

Insert Data into a Hash:
HSET user:1 name "John Doe" age 30
HGETALL user:1
LPUSH tasks "Task1" "Task2"
LRANGE tasks 0 -1
SMEMBERS team
SADD team "Alice" "Bob"
ZADD leaderboard 100 "Player1" 200 "Player2"
ZRANGE leaderboard 0 -1 WITHSCORES

```


- Install and configure Prometheus and Grafana to collect and analize metrics from Redis.
- Install and update repo
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```
- Install Prometheus opeartor using the chart
```bash
kubectl create namespace monitoring
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
```

- Vrify the the resources created
```bash
kubectl get all -n monitoring
```

- Expose Prometheus and Grafana services

```bash
kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus 9090:9090

kubectl port-forward -n monitoring service/prometheus-grafana 3000:80
```



- Check if the CRDs, including ServiceMonitor, are installed
```bash
kubectl get crds | grep servicemonitor
```

- Ensure the metrics exporter is available on port 9121
```bash
kubectl port-forward svc/redis-sentinel-metrics 9121:9121 -n redis
curl http://localhost:9121/metrics
```

Check if service monitor for redis is up and edit it so that it can expose it's metrics to be scraped by Prometheus.
```bash
kubectl get servicemonitor -n redis
kubectl edit servicemonitor -n redis
```

Under labels add release: prometheus
```bash
  labels:
  .....
    release: prometheus
```

- Performance Co-Pilo
[Installation](https://grafana.com/grafana/plugins/performancecopilot-pcp-app/?tab=installation)

- Installing on a local Grafana
Use the grafana-cli tool to install Performance Co-Pilot from the commandline

- Exec into the Grafana pod

```bash
kubectl get pods -n monitoring
kubectl -n monitoring exec -it <podName> -- sh
```
- List installed plugins

```bash
grafana cli plugins ls
```
- List available plugins
```bash
grafana cli plugins list-remote
```

- Install a specific version of a plugin
```bash
grafana cli plugins install <plugin-id> <version>
kubectl scale --replicas=3 deployment my-grafana -n monitoring
```

- Remove one plugin
```bash
grafana cli plugins remove <plugin-id>
```

```bash
grafana cli plugins install performancecopilot-pcp-app
```

- Deploy pmproxy on Your Kubernetes Cluster
Why do I need pmproxy
Deploy pmproxy as a Pod
```bash
kubectl create namespace pcp
```

```bash
kubectl apply -f pmproxy.yaml -n pcp
```

- Expose the pmproxy Service
```bash
kubectl apply -f pmproxy-svc.yaml -n pcp
```

- Port Forward the Service
```bash
kubectl port-forward -n pcp svc/pmproxy 30423:8080
```
- Test pmproxy
```bash
kubectl logs -n pcp <pmproxy-pod-name>
curl http://localhost:30423/metrics
```
- pmproxy is accessible via http://localhost:30423



kubectl run redis-client --namespace redis --restart='Never' --image redis:7.4.1-alpine --command -- sleep infinity

kubectl exec --namespace redis --tty -i redis-client -- sh


```bash
** Please be patient while the chart is being deployed **

Redis&reg; can be accessed on the following DNS names from within your cluster:

    redis-sentinel-master.redis.svc.cluster.local for read/write operations (port 6379)
    redis-sentinel-replicas.redis.svc.cluster.local for read-only operations (port 6379)



To get your password run:

    export REDIS_PASSWORD=$(kubectl get secret --namespace redis redis-sentinel -o jsonpath="{.data.redis-password}" | base64 -d)

To connect to your Redis&reg; server:

1. Run a Redis&reg; pod that you can use as a client:

   kubectl run --namespace redis redis-client --restart='Never'  --env REDIS_PASSWORD=$REDIS_PASSWORD  --image docker.io/bitnami/redis:7.4.1-debian-12-r2 --command -- sleep infinity

   Use the following command to attach to the pod:

   kubectl exec --tty -i redis-client \
   --namespace redis -- bash

2. Connect using the Redis&reg; CLI:
   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-sentinel-master
   REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h redis-sentinel-replicas

To connect to your database from outside the cluster execute the following commands:

    kubectl port-forward --namespace redis svc/redis-sentinel-master 6379:6379 &
    REDISCLI_AUTH="$REDIS_PASSWORD" redis-cli -h 127.0.0.1 -p 6379

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - metrics.resources
  - replica.resources
  - master.resources
```





#!/bin/sh
export REDISCLI_AUTH=password
while true
do
    CURRENT_PRIMARY=$(redis-cli -h redis-sentinel-headless -p 26379 SENTINEL get-master-addr-by-name mymaster)
    CURRENT_PRIMARY_HOST=$(echo $CURRENT_PRIMARY | cut -d' ' -f1 | head -n 1)
    echo "Current master's host: $CURRENT_PRIMARY_HOST"
    redis-cli -h ${CURRENT_PRIMARY_HOST} -p 6379 INCR mycounter
    sleep 1
done