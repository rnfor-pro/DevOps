#!/bin/bash

# Docker

sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock

# Trivy

sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update -y
sudo apt-get install trivy -y       

# Jenkins

sudo apt update -y
# sudo apt install fontconfig openjdk-17-jre -y
sudo apt-get install openjdk-11-jdk
java -version
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins



# Rename hostname
# to uninstall openjdk

# To uninstall OpenJDK (if installed). First check which OpenJDK packages are installed.

# sudo dpkg --list | grep -i jdk
# To remove openjdk:

# sudo apt-get purge openjdk*
# Uninstall OpenJDK related packages.

# sudo apt-get purge icedtea-* openjdk-*
# Check that all OpenJDK packages have been removed.

# sudo dpkg --list | grep -i jdk

echo "------------changing hostname--------------"
sudo hostnamectl set-hostname jenkins_server
bash