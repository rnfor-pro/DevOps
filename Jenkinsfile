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
  -Dsonar.host.url=http://52.14.168.43:9000 \
  -Dsonar.login=sqp_cd04b953d15f86fd96f9ac31a3edce2a6de2fe36"
      }
    }
  }
}
