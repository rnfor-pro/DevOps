# Deploy Netflix Clone on AWS Cloud using Jenkins - DevSecOps Project!

DevSecOps Pipeline Solution built using Jenkins as the CI tool, with SonarQube, OWASP, and Trivy for security and vulnerability detection. Docker is used for containerizing the app, and ArgoCD enables Continuous Delivery/Deployment to AWS EKS. Helm makes managing the Kubernetes applications a breeze. With the power of Prometheus and Grafana, we gain valuable insights into the application’s performance, cluster health, and pipeline metrics.

- Prerequisites

  - [AWSCLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#:~:text=Install%20or%20update%20to%20the%20latest%20version%20of%20the%20AWS%20CLI)

  - [Terraform](https://developer.hashicorp.com/terraform/install)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

[Fork the github repo](https://github.com/rnfor-pro/monitoring-logging.git) and clone it on your local machine.
```
git clone < repo_url>
```
```
cd monitoring-logging/Infrastructure
```

```
terraform init
terraform plan
terraform apply
```

Access Jenkins UI.
---

`
hostIP:8080
`
- Install all the below plugins by going to Manage Jenkins → plugins and select available plugins.
  - Docker
  - Docker commons
  - Docker pipeline
  - Docker API
  - docker-build-step
  - Prometheus metrics
  - Email extension template
  - Eclipse Temurin installer
  - SonarQube Scanner
  - NodeJS
  - OWASP Dependency-Check
  - Blue Ocean
Scroll all the way down and check the restart jenkins button to restart jenkins  

SonarQube
---

Run SonarQube on your Jenkins server as  a Docker Container and access its UI.

- SSH into your Jenkins server.
- Confirm docker daemon is active
```
sudo systemctl status docker
```
- Run sonarqube as a container
```
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community
```
- Access sonarqube on port 9000
`
<instance_public_ip>:9000
`
- Default username is admin and password is admin

Prometheus Exporter Configuration
---
Let’s finalize Prometheus installation by creating a systemd unit configuration file for Prometheus.
SSH into your monitoring server

```
sudo vi /etc/systemd/system/prometheus.service
```
```
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
``` 
This unit file is an essential part of setting up Prometheus as a systemd service. It ensures proper dependencies, restart behavior, and configuration for running Prometheus as a background service on a Linux system. The Prometheus service is configured to start after the network is online, and it will automatically restart in case of failure. The provided ExecStart command includes necessary parameters for Prometheus to operate effectively.

Next, we’ll enable and start Prometheus. Then, verify its status.
```
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus

```

We’ll access it through the public IP and on port 9090:
```
http://<your-server-ip>:9090
```
Node Exporter Configuration
---
Similarly, we’ll create a systemd unit configuration file for Node Exporter:

```
node_exporter --version
```
```
sudo vi /etc/systemd/system/node_exporter.service

```
```
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target


StartLimitIntervalSec=500
StartLimitBurst=5


[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter --collector.logind


[Install]
WantedBy=multi-user.target
```
Enable and start and check the status of node Exporter:
```
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
sudo systemctl status node_exporter

```
`
Access node exporter on <host_ip>:9100
`

Next, we’ll need to define scraping intervals and targets for metric collection by modifying our `/etc/prometheus/prometheus.yml` file. 
We’ll first add a job for the Node Exporter. This will also add a new target for Prometheus to monitor and scrape.
```
sudo vim /etc/prometheus/prometheus.yml
```

```
- job_name: node_export
    static_configs:
      - targets: ["localhost:9100"]
```

We'll use Promtool to check the syntax of the config. If it’s successful, we then go ahead and reload Prometheus configuration without restarting.
```
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
```


Grafana
---
We’ve already installed Grafana via the user data script. Let’s confirm its status.

```
sudo systemctl status grafana-server
```
Grafana User Interface can be accessed through the server `public IP on port 3000` by default. The default `username and password is admin`.
Click on data sources
<img width="1581" alt="Screenshot 2024-06-29 at 5 37 00 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/7d76e519-9f4a-4da6-a04c-88bef96505c8">

Click on prometheus
<img width="953" alt="Screenshot 2024-06-29 at 5 46 10 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/f32a9127-891d-4251-9631-d7e7a0c3df72">
Enter prometheus url as shown below then scroll down and click save
<img width="1140" alt="Screenshot 2024-06-29 at 5 50 29 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/3e1b8a29-5c88-44e7-a2cf-2fbbfd75f9e5">
Select Dashboard on the left menu bar, Click on New, the blue tab far right and select import.
<img width="1648" alt="Screenshot 2024-06-29 at 5 56 01 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/be6b547e-9e25-4568-b8ae-9b5ec2b46db3">
Enter ID `1860` and click on Load. 
<img width="1166" alt="Screenshot 2024-06-29 at 6 00 15 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/37f43989-3e55-4ac5-b803-f9716404e2b6">
Scrool all the way down and click in the search box, select Prometheus and click on Import
<img width="1107" alt="Screenshot 2024-06-29 at 6 05 07 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/351e47fc-1d7d-47d0-81d9-4d4048b71cf0">
Grafana UI view
<img width="1652" alt="Screenshot 2024-06-29 at 8 17 22 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/3a3e434c-2365-4ffa-81d9-9186a3b494e2">


[Follow video for further configurations]()

Likewise, let’s integrate Jenkins with Prometheus to monitor the CI/CD pipeline. 
Head over to `Manage Jenkins --> System and scroll all the way down to Prometheus tab`
check the `Add build parameter label to metrics` box, `Add Build status label to metrics`, `Process Disabled jobs`, scroll down abit and check `Collect metrics for each run per build [Important: read help before enabling this option]`, `Collect code coverage`, and  `Disable metrics` boxes
The click on `apply` and `save`

<img width="1032" alt="Screenshot 2024-06-29 at 6 36 35 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/9751e41d-d17a-4fab-81fc-107c88a8890b">
<img width="1060" alt="Screenshot 2024-06-29 at 6 37 11 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/88cd9f13-610d-4bed-be5b-b5bffb027afa">

Entry for Jenkins
---
```
sudo vim /etc/prometheus/prometheus.yml
```  

```
- job_name: 'jenkins'
    metrics_path: '/prometheus'
    static_configs:
      - targets: ['<jenkins-ip>:8080']
``` 

```
promtool check config /etc/prometheus/prometheus.yml
curl -X POST http://localhost:9090/-/reload
```
Then, you can use a POST request to reload the config.
```
curl -X POST http://localhost:9090/-/reload
```
Check the targets section in your prometheus UI you will see Jenkins is added to it

Let’s add Dashboard for a better view in Grafana

`Click On Dashboard –> + symbol or New –> Import` as you did before

Dashboard
Use Id `9964` and click on load

Select Prometheus as data source and click on Import
Now you will see the Detailed overview of Jenkins in grafana UI
<img width="1656" alt="Screenshot 2024-06-29 at 8 15 16 AM" src="https://github.com/rnfor-pro/DevOps/assets/67124388/88fcf946-39b7-41be-9990-4ab2918f5492">


Email extension template
---
`Go to your Gmail and click on your profile
Then click on Manage Your
<img width="1654" alt="Screenshot 2024-06-29 at 9 07 14 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/af5a9011-d43d-4ae2-98b1-35b8addf8b8b">

Google Account –> click on the security tab on the left side panel 
<img width="1657" alt="Screenshot 2024-06-29 at 9 13 43 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/760824bd-0668-40ba-badf-597e3d33d18c">
Provide mail password and click on turn on 2-factor authentication
<img width="1564" alt="Screenshot 2024-06-29 at 9 15 59 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/6ba452b1-afd6-4cf8-aa18-7e33d455e31b">
Click on done
<img width="1450" alt="Screenshot 2024-06-29 at 9 17 04 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/44903637-12b0-4de0-9fb0-521fb4636011">

2-step verification should be enabled.
<img width="1414" alt="Screenshot 2024-06-29 at 9 19 04 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/12a507d3-9fca-4a4b-abcd-93c1530dc7c3">
Type apps in the search bar and select apps passwords
<img width="1236" alt="Screenshot 2024-06-29 at 9 20 05 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/af2a769a-d916-4906-8687-88de8a0f0bf9">
Give it a title and click create
<img width="1324" alt="Screenshot 2024-06-29 at 9 21 32 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/eb5cd397-9956-40ab-b03f-04c7c70225c2">
Copy password and save in a secure place
<img width="1365" alt="Screenshot 2024-06-29 at 9 22 22 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/8cc8c76b-b771-479b-b13f-71a098f7092b">

Go to Manage jenkins --> System, scroll doen to `E-mail Notification`
<img width="1599" alt="Screenshot 2024-06-29 at 9 41 58 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/fc8ef423-2e97-4877-a20d-308af87326ce">
<img width="1566" alt="Screenshot 2024-06-29 at 9 44 59 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/ae6a9ea0-5d7e-4b67-8cee-aa78709814c7">
![Screenshot 2024-06-29 at 10 00 20 PM](https://github.com/rnfor-pro/playlist_2/assets/67124388/93b14681-5d01-42b4-aa31-514e0089632c)
![Screenshot 2024-06-29 at 9 51 12 PM](https://github.com/rnfor-pro/playlist_2/assets/67124388/d543ff16-ec0b-467e-8e61-4983aeb9e259)

Click on `save`
Go to `Manage Jenkins` --> `Credentials` --> `System` --> `Global credentials(unrestricted)` --> add credentials
<img width="1615" alt="Screenshot 2024-06-29 at 10 10 22 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/211a1d5b-16d4-4dac-b537-69c2c9d4212e">
Go back to manage jenkins and scroll down to Extended E-mail
<img width="852" alt="Screenshot 2024-06-29 at 10 15 12 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/c9031b29-68c0-4712-9ab9-cd9b741959ff">

Sceoll doen to `DeTault triggers`
<img width="1456" alt="Screenshot 2024-06-29 at 10 19 19 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/fd7c31ef-101e-46bc-82b0-c412d027ed85">

[video]()

Eclipse Temurin installer
---
Configure Nodejs and Java in Global Tool Configuration

`Goto Manage Jenkins → Tools → Install NodeJs(16)→ Click on Apply and Save`
<img width="1641" alt="Screenshot 2024-06-30 at 4 58 47 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/8f62cf3b-0484-4561-9439-4af14e4dd73f">

`Goto Manage Jenkins → Tools → JDK installations → Click on Apply and Save`
<img width="1563" alt="Screenshot 2024-06-30 at 5 07 19 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/587fefd9-c98c-42f1-8b0d-d05e80c1d46f">

Click on Install from `adoptium.net` and select `jdk-17.0.8.1+1` then click on `apply` and `save` 
<img width="1636" alt="Screenshot 2024-06-30 at 5 08 30 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/118093b7-bd6f-4a43-848e-0e1d1832a2a7">

[video]()

SonarQube scanner
---
Configure Sonar Server in Manage Jenkins
Access SonarQube UI , Sonarqube works on Port 9000, so `Public IP>:9000`.

Click on Administration → Security → Users → Click on Tokens and Update Token → Give it a name → and click on Generate Token
<img width="1248" alt="Screenshot 2024-06-30 at 5 22 44 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/736bf003-e117-4733-bd1f-149967a8d6cc">
[video]()

copy Token
`Goto Jenkins Dashboard → Manage Jenkins → Credentials → Global --> Add Credentials

<img width="1487" alt="Screenshot 2024-06-30 at 5 27 50 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/adef3c80-c20f-4de0-ad56-be0ee2243469">

Click in the box under `kind` and select `secret text` add Secret text created earlier in snarqube enter `ID` and `d  escription` then click on `create`. 


<img width="1485" alt="Screenshot 2024-06-30 at 5 29 23 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/168a6abe-6d99-4dde-8aa1-f82f0ff31061">

Now, go to Dashboard → Manage Jenkins → System --> scroll down to `SonarQube servers` and click on `add sonarqube`.

<img width="1313" alt="Screenshot 2024-06-30 at 5 40 45 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/49d7db8a-cde8-461e-95e1-8134485318ca">

<img width="1476" alt="Screenshot 2024-06-30 at 5 44 39 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/008056f2-ec06-4f86-b667-13b1e6888db7">


[video]()

The Configure System option in Jenkins is used to configure different servers
Global Tool Configuration is used to configure different tools that we installed using Plugins

We will install a sonar scanner in the tools.
Go to Manage jenkins --> tools --> `SonarQube Scanner installations`

<img width="1560" alt="Screenshot 2024-06-30 at 5 54 08 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/82eaa7d5-18bd-41c4-adfd-f2779fcc0a3f">

[video]()

In the Sonarqube Dashboard add a quality gate.
<img width="1422" alt="Screenshot 2024-06-30 at 6 20 14 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/f378ba8b-65f6-473a-9bc0-5ae23cdbce0c">

<img width="968" alt="Screenshot 2024-06-30 at 6 21 19 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/b6fee4d2-7a3b-480a-a5cd-1a6a291ae216">

<img width="1449" alt="Screenshot 2024-06-30 at 6 22 01 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/c3f27e11-5455-4c42-b690-a2b159a06426">

<img width="1515" alt="Screenshot 2024-06-30 at 6 23 13 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/2e0c7ae6-b676-41ff-bd46-4e2108be980e">

<img width="1624" alt="Screenshot 2024-06-30 at 6 24 30 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/85dd3e0d-1ada-4f81-b341-a803a092bbe2">


Create a webhook by giving jenkins url to sonarqube so they can connect.
`
Administration–> Configuration–>Webhooks
`

<img width="1492" alt="Screenshot 2024-06-30 at 5 56 23 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/e6489ac1-ee8b-48cf-9379-222b63fb133a">

<img width="1605" alt="Screenshot 2024-06-30 at 5 58 16 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/07bd0acd-db92-42e4-bd4e-7169eb0e4e32">


in url section of quality gate
`
<http://jenkins-public-ip:8080>/sonarqube-webhook/
`
Let’s go to our Pipeline and add the script in our Pipeline Script on jenkins UI.
[video]()

```
pipeline{
    agent any
    tools{
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME=tool 'sonar-scanner'
    }
    stages {
        stage('clean workspace'){
            steps{
                cleanWs()
            }
        }
        stage('Checkout from Git'){
            steps{
                git branch: 'main', url: 'https://github.com/rnfor-pro/monitoring-logging.git'
            }
        }
        stage("Sonarqube Analysis "){
            steps{
                withSonarQubeEnv('sonar-server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=Netflix \
                    -Dsonar.projectKey=Netflix '''
                }
            }
        }
        stage("quality gate"){
           steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'Sonar-token'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
    }
    post {
     always {
        emailext attachLog: true,
            subject: "'${currentBuild.result}'",
            body: "Project: ${env.JOB_NAME}<br/>" +
                "Build Number: ${env.BUILD_NUMBER}<br/>" +
                "URL: ${env.BUILD_URL}<br/>",
            to: 'nfor.rudolph1@gmail.com',
            attachmentsPattern: 'trivyfs.txt,trivyimage.txt'
        }
    }
}
```

SonarQube Report
<img width="1587" alt="Screenshot 2024-06-30 at 7 00 24 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/46761940-2390-4b08-9f7c-881bae354104">

Jenkins server performance and Builds execution in Grafana UI

<img width="1642" alt="Screenshot 2024-06-30 at 7 01 02 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/d7f41ac6-1f86-47ea-8dd9-184c89622c15">

OWASP Dependency Check
---
`Goto Dashboard → Manage Jenkins → Tools → Dependency check`

Add Dependency-Check -> under name add `DP-Check`

Check install automatically and select `install from github`

For version go with `dependency-check 6.5.1`

Click on Apply and Save.

<img width="1573" alt="Screenshot 2024-07-01 at 9 18 15 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/26671ee6-6bf6-4068-b0d7-9257f9aa44d0">
<img width="1559" alt="Screenshot 2024-07-01 at 9 20 25 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/f2ed08e6-2749-4f6e-9d52-60452c943097">

Now go configure → Pipeline and add this stage to your pipeline and build.

```
stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
```

Docker Image Build and Push
---
Now, goto Dashboard → Manage Jenkins → Tools → Docker installation
<img width="1645" alt="Screenshot 2024-07-01 at 9 24 09 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/012c527f-5bb5-4a2f-8341-4197af699b84">

Add DockerHub Username and Password under Global Credentials [video]()

Manage Jenkins --> Credentials --> System --> Credentials --> Global credentials (unrestricted) --> add credentials
<img width="1593" alt="Screenshot 2024-07-01 at 9 55 04 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/fe7fe0c9-750d-42c5-8060-1219b1cb0556">

We are not going to configure system because our dockerhub repositor is public

Create an account with [the movie database](https://www.themoviedb.org/?language=en-US)
Next, we will create a TMDB API key

Open a new tab in the Browser and search for TMDB
<img width="1444" alt="Screenshot 2024-07-01 at 10 21 19 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/32fcbcc8-28a6-436b-8a35-b46f5376c56b">
Click on the first result, you will see this page

Click on the Login on the top right. You will get this page.

You need to create an account here. click on click here. I have account that’s why i added my details in the username and passwod tab.
<img width="1602" alt="Screenshot 2024-07-01 at 10 42 04 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/8da63710-7e37-4ea8-9e50-09c11bdb825a">

once you create an account you will see this page.
<img width="1608" alt="Screenshot 2024-07-01 at 10 25 02 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/8a310b7f-0dd2-4769-87dd-0cfdd8851e67">

Let’s create an API key, By clicking on your profile and clicking settings.
<img width="1574" alt="Screenshot 2024-07-01 at 10 25 37 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/8cf69788-5ca5-4bae-b8f8-ca0e7b60c89e">

Now click on API from the left side panel.
<img width="159" alt="Screenshot 2024-07-01 at 10 33 18 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/81ad7001-1eb5-4f45-955f-5b23f8ad8042">

Now click on create
<img width="773" alt="Screenshot 2024-07-01 at 10 34 04 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/dfb8fa26-72af-452c-8ab0-f4d2bc945700">

Click on Developer
<img width="773" alt="Screenshot 2024-07-01 at 10 34 30 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/15d347c9-4e48-4d17-8ff4-20e6300501d7">

Accept the terms and conditions.
<img width="781" alt="Screenshot 2024-07-01 at 10 34 55 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/d7a4a07f-10cb-4016-ae58-202df7ab6612">

Provide basic details
<img width="822" alt="Screenshot 2024-07-01 at 10 36 32 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/a77f7884-12d7-441c-85f7-f15643b910fc">

Click on submit and you will get your API key.
<img width="1394" alt="Screenshot 2024-07-01 at 10 37 11 AM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/1c228602-e72a-4a05-82d8-1cb3110c54f8">


Add this stage to Pipeline Script and build
```
stage("Docker Build & Push"){
            steps{
                script{
                   withDockerRegistry(credentialsId: 'docker', toolName: 'docker'){
                       sh "docker build --build-arg TMDB_V3_API_KEY=xxxxxxxxxxx -t netflix ."
                       sh "docker tag netflix rudolphnfor/netflix:latest "
                       sh "docker push rudolphnfor/netflix:latest "
                    }
                }
            }
        }
        stage("TRIVY"){
            steps{
                sh "trivy image rudolphnfor/netflix:latest > trivyimage.txt"
            }
        }
```

When you log in to Dockerhub, you will see a new image is created

Now add the stage below and build your application as a docker container, access it on `jenkins_public_ip:8081`

```
stage('Deploy to container'){
            steps{
                sh 'docker run -d --name netflix -p 8081:80 rudolphnfor/netflix:latest'
            }
        }
```

EKS
---
To follow along in our continuous delivery steps with `ArgoCD` forllow the link below to set up an EKS cluster

[steps here](https://github.com/rnfor-pro/monitoring-logging/blob/main/kube-EKS/README.md)

Install helm [here](https://helm.sh/docs/intro/install/)



ArgoCD
---
ArgoCD is a declarative, GitOps continuous delivery tool for Kubernetes. It allows users to maintain and manage Kubernetes applications using Git repositories as the source of truth for the desired application state. ArgoCD automates the deployment, monitoring, and lifecycle management of applications in Kubernetes clusters.

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.4.7/manifests/install.yaml
```

Let’s expose the ArgoCD service

```
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```
Install Node Exporter Using Helm
---

We’ll use Node Exporter to collect our Kubenetes Cluster Nodes system-level metrics. Helm is a requisite though and can be installed via this link if you don’t already have it. Helm is a package manager for Kubernetes applications. It simplifies the process of defining, installing, and upgrading even the most complex Kubernetes applications. Install Node Exporter using Helm through the following steps:

a. Add the Prometheus Community Helm repository

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```


b. Create a Kubernetes namespace for the Node Exporter

```
kubectl create namespace prometheus-node-exporter
```

c. Install the Node Exporter using Helm

```
helm install prometheus-node-exporter prometheus-community/prometheus-node-exporter --namespace prometheus-node-exporter
```

Add a Job to scrape metrics on nodeip:9001/metrics. We can achieve this by adding the following configuration to our prometheus.yml file and reloading Prometheus afterward. `Run on your monitoring server`

```
sudo vim /etc/prometheus/prometheus.yml
```

```
 - job_name: "Netflix App"
    metrics_path: "/metrics"
    static_configs:
      - targets: ["node1Ip:9100"]
```
```
promtool check config /etc/prometheus/prometheus.yml
```

Use a POST request to reload the config.
```
curl -X POST http://localhost:9090/-/reload
```

Configuring ArgoCD
---

[video]()

`Back to your terminal where you were running your kubectl comands previously`

Let’s fetch ArgoCD LoadBalancer URL.

```
export ARGOCD_SERVER=`kubectl get svc argocd-server -n argocd -o json | jq --raw-output '.status.loadBalancer.ingress[0].hostname'`
echo $ARGOCD_SERVER
```
Copy and paste it in a browser. Click on the ‘Advanced’ settings and the url

To login, default username is “admin” but we’ll need to fetch the password like so:

```
export ARGO_PWD=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
echo $ARGO_PWD
```
<img width="1593" alt="Screenshot 2024-07-01 at 1 11 52 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/9a339cd4-cd02-4c8e-b168-5df373762e0b">
[video]()

Let’s connect ArgoCD to our repo.
---

Navigate to Settings → Repositories → Connect Repo Using HTTPS
<img width="1440" alt="Screenshot 2024-07-01 at 1 16 59 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/d55656df-0d8d-4e43-8f81-4563c2e230b6">
<img width="1440" alt="Screenshot 2024-07-01 at 1 16 59 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/3356dd1e-9325-4ccc-a873-8d6ff34bcb19">


<img width="1626" alt="Screenshot 2024-07-01 at 1 25 42 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/e85fea58-5f67-45af-91e3-7dbe48a85239">
Click on `connect` .

<img width="1472" alt="Screenshot 2024-07-01 at 1 28 56 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/00768ab5-4c58-4939-b819-3e8e4f82e401">

Create new app which will fetch the data present in the `kubernetes` folder in github
<img width="1657" alt="Screenshot 2024-07-01 at 1 33 31 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/2b75913d-6e84-443b-bf47-b21066893dc5">

<img width="1642" alt="Screenshot 2024-07-01 at 1 37 12 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/faf8ab5e-914a-4d87-a537-70e0d38f46f2">

For `Cluster URL` enter `https://kubernetes.default.svc`


Next, we head to Manage Applications → New App

<img width="1652" alt="Screenshot 2024-07-01 at 1 51 57 PM" src="https://github.com/rnfor-pro/playlist_2/assets/67124388/b29804ca-bf2a-45b6-88cd-3418e36e5502">

We’ll access the application through the `node public IP on port 30007` (ensure you enable port 30007 on the Node Cluster Security Group).

To destroy this setup, we’ll simply run terraform destroy first in our Infrastructure directory and then in our kube-EKS directory.





