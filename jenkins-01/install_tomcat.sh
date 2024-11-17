#!/bin/bash
#Author:Prof Elvis N
#Company: Etech Co. llc
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat
sudo apt update -y
sudo apt install default-jdk -y
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.97/bin/apache-tomcat-9.0.97.tar.gz
sudo tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R tomcat:tomcat /opt/tomcat/
sudo chmod -R u+x /opt/tomcat/bin
sudo hostnamectl set-hostname tomcatsrv