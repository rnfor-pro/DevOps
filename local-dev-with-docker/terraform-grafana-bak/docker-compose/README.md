# Setting Up Prometheus and Grafana on Docker

## Why Use Docker for Prometheus and Grafana?

Docker simplifies the deployment and management of Prometheus and Grafana. Here's why containerization is beneficial for these monitoring tools:

- **Easy deployment**: Docker containers package all dependencies, making installation straightforward.
- **Scalability**: You can easily scale your monitoring setup as your infrastructure grows.
- **Consistency**: Containers ensure consistent environments across development, testing, and production.
- **Simple updates**: Upgrading to new versions is as simple as pulling the latest Docker images.

## Prerequisites for Installing Prometheus and Grafana on Docker

Before you begin, ensure you have:

- Docker and Docker Compose installed on your system
- Basic understanding of containerization concepts
- Sufficient system resources (CPU, RAM, and storage)
- Available network ports for Prometheus and Grafana

---

## Setting Up Prometheus

1. **Create a Docker network for Prometheus and Grafana**:
   ```bash
   docker network create monitoring

2. **Create a Prometheus configuration file named prometheus.yml**:
```yaml
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['prometheus:9090']
```

3. ***Create a Docker Compose file named docker-compose.yml:***

```yaml
version: '3.8'
services:
  prometheus:
    image: prom/prometheus
    ports:
      - 9090:9090
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - monitoring

networks:
  monitoring:
    external: true
```

4. ***Run Prometheus:***

```bash
docker-compose up -d
```
5. ***Verify the Prometheus container is running:***

```bash
docker ps
```
## Adding Grafana to the Setup
1. ***Update the docker-compose.yml file to include Grafana:***
```yaml
  grafana:
    image: grafana/grafana
    ports:
      - 3000:3000
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=your_password
    networks:
      - monitoring
```
2. ***Run the updated Docker Compose configuration:***

```bash
docker-compose up -d
```

3. ***Access the Grafana web interface:***
- Access the Grafana web interface:

[http://localhost:3000]

## Collecting Metrics from Your Applications

1. ***Add scrape configurations to prometheus.yml so that Prometheus can also monitor Grafana:***

```yaml
  - job_name: 'grafana'
    static_configs:
      - targets: ['grafana:3000']
```

2. ***Restart the Prometheus container to apply changes:***

```bash
docker-compose restart prometheus
```
3. ***Log in to Grafana:***
- Default username is: admin
- Password is: your_password

## To monitor my Docker environment

Add cAdvisor to your docker-compose.yml:
```yaml
cadvisor:
    image: gcr.io/cadvisor/cadvisor
    ports:
      - 8080:8080
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro # Add only if containers run on Mac
    networks:
      - monitoring
```
Update Prometheus configuration to scrape cAdvisor metrics

```yaml
  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080'] 
```
Restart your containers
```bash
docker-compose up -d
```

Create a Docker-specific dashboard in Grafana using cAdvisor metrics

