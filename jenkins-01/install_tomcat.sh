#!/bin/bash
#Author:Prof Elvis N
#Company: Etech Co. llc
sudo apt update
sudo apt-get install openjdk-11-jdk
sudo groupadd tomcat
sudo useradd -g tomcat -d /opt/tomcat -s /bin/false tomcat
sudo mkdir -p /opt/tomcat
cd /opt
sudo chown -R tomcat:tomcat tomcat
cd /tmp
sudo wget  https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.33/bin/apache-tomcat-10.1.33.tar.gz

sudo tar -xvf /tmp/apache-tomcat-10.1.33.tar.gz -C /opt/tomcat
sudo ln -s /opt/tomcat/apache-tomcat-10.1.33 /opt/tomcat/latest
sudo chown -RH tomcat: /opt/tomcat/latest
sudo sh -c 'chmod +x /opt/tomcat/latest/bin/*.sh'
echo "Apache Tomcat installation completed successfully."
sudo hostnamectl set-hostname tomcatsrv
bash