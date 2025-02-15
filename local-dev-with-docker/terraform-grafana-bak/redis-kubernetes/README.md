# Redis on Kubernetes using manifests files

<a href="https://youtu.be/JmCn7k0PlV4" title="redis-k8s"><img src="https://i.ytimg.com/vi/JmCn7k0PlV4/hqdefault.jpg" width="20%" alt="redis-k8s" /></a> 

Create a cluster with [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)

[Redis Configuration](https://redis.io/docs/latest/operate/oss_and_stack/management/config/#:~:text=Redis%20configuration-,Redis%20configuration,-Overview%20of%20redis)


## Redis on Kubernetes using manifests
There are 2 main things to take into consideration.
1. Replication.
I am going to deploy 3 instances of redis to replicate, Redis has the concept of master and replicas. We will always have one master and a minimum of 2 replicas.  We also want to be able to scale this up. In a distributed system like K8s pods can come and go so we need to ensure that these pods can find the current master. If a pod dies and come back we need to be able to find and join the current master.
2. High availability.
The second most important thing is high availability, when the master dies the sentinel job is to promote another replica to a master so the sentinel does the fail over so we are going to be running the redis sentinel to form a cluster out of the redis pods.
In this demo sentinel is deployed seperate from redis replicas. Sentinel's job is to form a cluster and do the automatic failover if one of the master dies. When a sentinel starts the first thing it would do is to figure who the master is and out of the redis relicas, any of them can be the master so we need to do something so that sentinel can discover who the master is, probably an init container. Once the sentinel figure out it's master's address it wll do everything else automatically. It will contact the master, find the replicas, find the other sentinels and form a cluster. this will allow us to scale the sentinels at will and we will need a minimum of 3 else the cluster failover will not work.

The fundermental thing to know about sentinel before deploying is there is no HA set up which is safe so you need to test your redis instances to make sure they can tolerate disruption. So if a pod dies and come back up we wanna make sure we don't have any disruption and you wanna make sure that your application can tolerate this disruption. 

To follow along make sure you have a k8s cluster.

I am using kind on mac for this et up.

- Create a K8s cluster
```bash
kind create cluster --name redis --image kindest/node:v1.31.2 
```
- Verify
```bash
kubectl get nodes
```

- Create a Namespace

```
kubectl create ns redis
kubectl get ns | grep redis
```

- Storage Class
Storage class allows us to define the type of storage we want to attach to kubernetes and then we can use a persistent volume to attach that storage to a container.

```
kubectl get storageclass
```
- Output
Your output might be different based on your cloud provider. I am using the default which is basically a volume on my host as seen below.

```
NAME                 PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
standard (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  84s
```

- Deployment: Redis kubernetes manifests and configurations deep dive.
In this demo I deploy a bunch of redis pods and then help them replicate, authenticate and form a cluster. 
The first thing is the configuration, in my redis ConfigMap I am using the configurations for redis 7.4.1 .
  - Authentication: In order to Authenticate we need to put the password in the configuration file.
    `requirepass a-very-complex-password-here` --> used by any app or cli to authenticate to redis pods
    `masterauth a-very-complex-password-here` --> used by any of the replicas to talk to the master. Since we are going to be running multiple pods, the plan is to run pod zero as the master and because we are running a cluster in failover at any point in time any given pod can become a master that's why I keep the password between the master and the required pass thesame. This will allow repicas to talk to the master and the master to talk to the replicas

  - Replication: The `# slaveof redis-master-0.redis-master.svc.cluster.local 6379` line in the configuaration tells the redis instances where the master address is. It is commented out in the configuration because the value is dynamicaly generated on the fly. When redis starts up we are going to want to make pod zero the master and then the sentinels will take over so when cluster failover happens the sentinels will be able to promote any replica to a master. So it is very important not to hard code `slaveof` value.

 - Persistence: Redis provide a range of persistence options `RDB and AOF` modes.
  The rdb persistent performs point-in-time snapshots of your datasets at specified intervals.
  This is good for performance because it takes up a bunch of compute each time redis dumps it's files to disk. But it is also not as durable because if redis had to die within that interval there's a chance of data loss.
  AOF mode is a little bit better for durability because it writes every transaction as it happens to disk. This is good for durability but not so good for performance. The redis community recommends running both.
  `dir "data"`. The `dir` key in the redis configurations tells redis where to write it's data to and the `data` is going to be where our persistent volume attaches to the containers.
  `appendonly yes` mode is turned on in the configuration and `appendfilename "appendonly.aof"` key specifies the appendonly filename you want to use in our case is appendonly.aof.
  To turn on `rdb` mode you can just specify which db file you want to use in the configuration using `dbfilename dump.rdb`.  

- Statefulset reacap: I am using a statefulset since redis is a stateful workload for k8s. The reason is we need to provide a stable DNS for each of of our redis pods such as redis-0, redis-1, redis-2 and so forth as we scale up. Each pod has to be individually adressable which is not something a deployment can do. Statefulset give our pods a persistent network identity and persists accross reboots.
It also give us the ability to generate seperate volumes on the fly and mount them in each of the pods automatically. This is something that a deployment does not do.
As shown below, we are going to be starting up redis without custom configurations.
```yaml
      containers:
      - name: redis
        image: redis:7.4.1-alpine
        command: ["redis-server"]
        args: ["/etc/redis/redis.conf"]
```
Here we monut our volume into the container and redis will write data to that path
```yaml
        volumeMounts:
        - name: data
          mountPath: /data
```
The below VolumeClaimTemplate tells the statefulset to issue storage using the storage class we have.
Every pod which is part of the statefulset will get it's own persistent volume and it will be automatically  mounted into the container.
```yaml
  volumeClaimTemplates:
  - metadata:
      name: data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "standard"
      resources:
        requests:
          storage: 64Mi
```
We also have a headless service type `clusterIP: None` and this will give every pod a stable DNS record; redis-0. redis-1, redis-2 and so forth.

```yaml
spec:
  clusterIP: None
  ports:
```
You will notice that I am creating another volumeMount for the redis configMap and mounting it to 
`/etc/redis` but if you take a look at the volume it is not really a configmap it is an empty directory
`THIS IS REALLY IMPORTANT BECAUSE REDIS NEEDS WRITE ACCESS TO IT'S CONFIGURATION` this is because at any given time any redis master might be promoted to a master so it needs to be writing details to the configuration on the fly. For that reason it is not great to be using a cnfigmap because if the pod recreates it'll get the configmap back and the details will change and it will not know how to connect to the curent master, it won't know how to find the sentinels either. This is important because if the redis pod dies and gets recreated we don't want it to get the default config again we want it's configuration file generted on the fly.

```yaml
        volumeMounts:
        - name: data
          mountPath: /data
        - name: redis-config
          mountPath: /etc/redis/
      volumes:
      - name: redis-config
        emptyDir: {}
      - name: config
        configMap:
          name: redis-config
```
To achieve that we have an init container this is the container that starts up before all other containers in the pod. His job is to generate a configmap on the fly as shown below. We have a volume mount and we are mounting the configmap into `/tmp/redis/.` and we will copy the /tmp/redis into the real redis location `/etc/redis/redis.conf` . so this container wil attempt to contact the sentinel to figure out who the master is, if the sentinel are not running it will default to redis-0 and if it is redis zero it will do nothing because it is the master. All this is aechieved by running a bash script.

```yaml
    spec:
      initContainers:
      - name: config
        image: redis:7.4.1-alpine
        command: [ "sh", "-c" ]
        args:
          - | 
          ....
          ...        volumeMounts:
        - name: redis-config
          mountPath: /etc/redis/
        - name: config
          mountPath: /tmp/redis/.

```
As you can see we are heavily reliant on sentinel to do the failover, do the leader election and we just contact it and point to that master.

## Deployment: Redis nodes 
```
kubectl apply -n redis -f ./kubernetes/redis/redis-configmap.yaml
kubectl apply -n redis -f ./kubernetes/redis/redis-statefulset.yaml

kubectl -n redis get pods
kubectl -n redis get pv

kubectl -n redis logs redis-0
kubectl -n redis logs redis-1
kubectl -n redis logs redis-2
```
After ensuring that each instance is healthy by getting the logs of each pod as seen above we want to test replication status.
## Test replication status

```
kubectl -n redis exec -it redis-0 -- sh
redis-cli 
auth a-very-complex-password-here
info replication
```

## Deployment: Redis Sentinel (3 instances)
Based on the set up we have 1 master and 2 replicas currently running what if one of the replicas die? it doesn't matter because the replicas will find it's master anyways but what if the master dies?
this is when the sentinel comes in. The job of the sentinel is to form a cluster and also allow for cluster failover so if the master dies the sentinel will promote one of the replicas to a master.
   - For sentinel we are running 3 replicas of `redis 7.4.1` and we exposing `port 500` which is the port that the sentinels use to talk to each other. We also mount an ampty configuration volume. Additionally we are using an init container to generate our configurations on the fly that is why we don't have a configmap for the sentinel. This is very easy to do with the sentinel because when a sentinel pod comes up the only thing it needs to know is where is one of the redis instances so we can loop through a bunch of address names for example redis=0, redis-1 and redis-2 and the init container can go and contact any of those instances and in the case of redis-1 or redis-2 being down it can just loop through that list and find one of them that should be up and then contact it, find out what the master address is and then point the redis sentinel to the master this is all that the sentinel needs. Once it connects to the master it will be able to find all the replicas that are part of the repliaction in the cluster and it will find all other sentinel addresses as well and this is part of the behavior of the sentinel. 

```
kubectl apply -n redis -f ./kubernetes/sentinel/sentinel-statefulset.yaml

kubectl -n redis get pods
kubectl -n redis get pv
```
To make sure that clustering worked we can take a look at the logs of one of the sentinel pod
```bash 
kubectl -n redis logs sentinel-0
```
From the logs we are going to see that it found master and 2 other sentinels

- Testing failover
We are going to test failover by deleting one of the pods precisely the master. Next I am going to see what the sentinel has done by getting the logs of `sentinel-0` we are going to see that it did a switch of the master and also indicate that it can connect to the slaves. It as well mark the current master as a slave and say `slave down` and we can run `kubectl get pod -o wide` and compare IP's to confirm that there has been a switch of the masters.
After identifying the master exec into the pod and confirm replication.

```bash
kubectl get pods -n redis
kubectl -n redis delete pod redis-0
kubectl -n redis logs sentinel-0
kubectl get pods -n redis -o wide
kubectl -n redis exec -it redis-2 sh
redis-cli 
auth a-very-complex-password-here
info replication
```

If we exec into sentinel zero and execute the same commands we will see that it has taken the role of a slave.

```bash
kubectl -n redis exec -it redis-0 sh
redis-cli 
auth a-very-complex-password-here
info replication
```

- What happens when one of the sentinels die
Nothing happens because the sentinel should come back up, loop through the addresses it's gonna contact each one of the node and ask who the master is then contact the master, find out who the replicas are and connect to the sentinels. This should pause no disruption into our replication.

```bash
kubectl get pods -n redis
kubectl -n redis delete pod sentinel-1
kubectl -n redis logs sentinel-1
kubectl get pods -n redis -o wide
```
