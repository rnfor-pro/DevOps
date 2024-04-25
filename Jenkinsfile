pipeline {
  agent any
  tools {
    maven 'maven'
  }
  stages{
    stage('1-cloning project repo'){
      steps{
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'maven', url: 'https://github.com/rnfor-pro/jenkins-01.git']])
      }
    }
    stage('2-cleanws'){
      steps{
        sh 'mvn clean'
      }
    }
    stage('3-mavenbuild'){
      steps{
        sh 'mvn package'
      }
    }
    stage('codequality'){
        steps{
       sh "mvn clean verify sonar:sonar \
  -Dsonar.projectKey=team9 \
  -Dsonar.projectName='team9' \
  -Dsonar.host.url=http://18.117.78.25:9000 \
  -Dsonar.token=sqp_f8584c203e5d45c40bf1c29f14a339e4e96169bf"
      }
    }
  }
}
