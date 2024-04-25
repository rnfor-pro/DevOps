pipeline {
  agent any
  tools {
    maven 'maven'
  }
  stages{
    stage('1-cloning project repo'){
      steps{
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'maven', url: 'https://github.com/etechDevops/etech-mavenApp.git']])
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
  -Dsonar.projectKey=team8 \
  -Dsonar.projectName='team8' \
  -Dsonar.host.url=http://54.200.42.180:9000 \
  -Dsonar.token=sqp_b520b6d68db3680ebe2fe6767529edfd4c99211d"
      }
    }
  }
}