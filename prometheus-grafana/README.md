Requirements: Only for Mac
Installing Docker desktop on mac
1. Install brew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

```bash
brew install [x]
brew cask install [gui_tool]
brew cask install docker
docker --version

```

Windows user:
daownload and follow prompts to install


[click here to install](https://docs.docker.com/desktop/setup/install/windows-install/)

Clone project repo:
```bash
git clone https://github.com/rnfor-pro/DevOps/tree/main/prometheus-grafana

cd DevOps
cd prometheus-grafana
```

## Install Prometheus & Grafana on Kubernetes (kube-prometheus-stack)
In this tutorial, we'll use the kube-prometheus-stack to install Prometheus and Grafana on Kubernetes. We'll explore how Prometheus comes pre-configured to monitor the underlying Kubernetes infrastructure and learn how to configure it to monitor our own applications. 
This guide is divided into three chapters:

1. Infrastructure set-up

2. Installation

3. Infrastructure Monitoring

4. Application Monitoring
---

1. Infrastructure set-up

### Create a kubernetes cluster using Kind

```bash
kind create cluster --config cluster-config.yaml
kubectl get nodes
```

2. Installation
---
First, ensure you have Helm installed on your machine by running the `helm version` command in your terminal.
We'll use the Prometheus Community Helm repository, which contains all Prometheus-related Helm charts including the kube-prometheus-stack.

### Here's how to set it up:

Add the Prometheus Community repository:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```

You can search for available charts:

```bash
helm search repo prometheus-community
```

To search specifically for the kube-prometheus-stack:
```bash
helm search repo prometheus-community/kube-prometheus-stack
```

To see all available version

```bash
helm search repo prometheus-community/kube-prometheus-stack --versions
```

For this tutorial, we'll install version 45.7.1 of the Kube Prometheus Stack. Here's the installation command:
```bash
helm install prometheus prometheus-community/kube-prometheus-stack --version 45.7.1 --namespace monitoring --create-namespace
```

This installation deploys four main components into your Kubernetes cluster:

1. Prometheus Operator: Automates the creation of your Prometheus instance and alert manager

2. Node Exporter: Extracts infrastructure metrics

3. Kube State Metrics: Collects Kubernetes platform metrics

4. Grafana: Visualization tool for metric data

You can verify the deployment by checking the pods in the monitoring namespace:
```bash
kubectl get pods -n monitoring
```

3. Infrastructure Monitoring

The gist of infrastructure monitoring is that Prometheus relies on exporters to extract metrics from particular targets. For example, a MySQL exporter would be designed to scrape metrics from MySQL, and a MongoDB exporter is designed to scrape metrics from MongoDB.

The kube-prometheus-stack comes pre-configured for infrastructure monitoring through two main exporters:

1. Node Exporter: Scrapes system-level metrics from Kubernetes nodes (CPU, memory usage, disk utilization)

2. Kube State Metrics: Collects metrics about Kubernetes objects' health, configuration, and availability

Because both of these exporters are shipped as part of the kube-prometheus-stack solution, the Prometheus instance is automatically configured to pull all of the metrics being collected by these exporters. This means we already have Kubernetes infrastructure-related metrics being saved into our Prometheus database, and we can access them right now.

To access the Prometheus UI, use port forwarding:
```bash
kubectl port-forward svc/prometheus-operated -n monitoring 9090:9090
```
You can then access the UI at `localhost:9090`. Here you can query metrics like `kube_pod_container_status_running` (collected by `kube-state-metrics`) to see the status of your pods, or node_load1 (collected by `node-exporter`) to see the system load average.

[Image]()

While it's possible to view metric data in the Prometheus UI, it's hard to make sense of it all in vector format. That's where Grafana comes in handy, as it allows us to create insightful dashboards based on all these Prometheus metrics.

For a more visual experience, access Grafana:
Access Grafana at `localhost:3000` with these default credentials:
```bash
kubectl port-forward svc/prometheus-grafana  -n monitoring 3000:80
```

- Username: admin

- Password: prom-operator

If these credentials don't work, you can retrieve the password using:
```bash
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```
Grafana comes pre-configured with dashboards that query Prometheus and visualize metrics in informative panels. These dashboards show how values change over time, whether they're system-level metrics collected via the node exporter or Kubernetes-specific metrics. You'll find dashboards showing the number of running pods across namespaces, running containers, and various other infrastructure metrics.

[inage]()

It's pretty cool how we get infrastructure monitoring out of the box without having to do any additional configuration.

4. Application Monitoring
Install hem charts for mongodb
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm search repo  prometheus-community 
```

Verify pods are up and running
```bash
kubectl create ns mongodb
kubectl apply -f mongodb 
kubectl get all -n mongodb
kubectl get pods -n mongodb
```

Deploy mongodb exporter in the same namespace to scrape data from mongodb /metrics andpoint
```bash
helm install mongodb-exporter prometheus-community/prometheus-mongodb-exporter -f mongodb-exporter/mongodb-exporter-values.yaml -n mongodb
```

View metric from mongodb exporter
```bash
kubectl port-forward  svc/mongodb-exporter-prometheus-mongodb-exporter 9216:9216 -n mongodb
```
View metrics `localhost:9216`

View service monitor responsible to help prometheus find data being exposed by mongodb-exporter at it's /metrics enpoint
```bash
Kubectl get servicemonitor -n mongodb
```

Qury mongodb data from prometheus UI

```bash
mongodb_up
```

deploy mongodb dashboard as code
```bash
kubectl apply -f mongodb-dashboard -n monitoring
```















