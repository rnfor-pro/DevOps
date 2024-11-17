#!/bin/bash
sudo apt update -y
sudo apt upgrade -y
# Add Jenkins repository key 
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
# Add Jenkins repository to sources list
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
# Update package lists
sudo apt-get update -y
# Install Jenkins
sudo apt-get install -y jenkins 
# Install fontconfig and OpenJDK 17
sudo apt-get install -y fontconfig openjdk-17-jre
# Enable Jenkins service
sudo systemctl enable jenkins
# Fetch public IP address using curl
public_ip=$(curl -s https://api.ipify.org)
# Print the fetched IP address along with port 8080
echo "Your Application is running on: $public_ip:8080"
echo "Please use the following initial password to unlock Jenkins:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "script is running successfully……!!😀" 
sudo apt install maven -y 
# Docker
sudo apt-get update -y
sudo apt-get install docker.io -y
sudo usermod -aG docker ubuntu
newgrp docker
sudo chmod 777 /var/run/docker.sock
sleep 7
sudo hostnamectl set-hostname jenkins-svr

# Troubleshooting
# If your jenkins is not running run the commands below
JAVA_VERSION=$($JAVA -version 2>&1 | sed -n ';s/.* version "\([0-9]*\)\.\([0-9]*\)\..*".*/\1\2/p;')
sudo systemctl start jenkins
# sudo systemctl status jenkins

    
# Do NOT RUN THE COMMANDS BELOW UNLESS YOU WANT TO UNINSTALL JAVA
# to uninstall openjdk

# To uninstall OpenJDK (if installed). First check which OpenJDK packages are installed.

# sudo dpkg --list | grep -i jdk
# To remove openjdk:

# sudo apt-get purge openjdk*
# Uninstall OpenJDK related packages.

# sudo apt-get purge icedtea-* openjdk-*
# Check that all OpenJDK packages have been removed.

# sudo dpkg --list | grep -i jdk




    