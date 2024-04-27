pipeline {
  agent any
  tools {
    maven 'maven'
  }
  stages{
    stage('1-cloning project repo'){
      steps{
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github', url: 'https://github.com/rnfor-pro/jenkins-01.git']])
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
  -Dsonar.projectKey=team10 \
  -Dsonar.host.url=http://3.139.233.127:9000 \
  -Dsonar.login=sqp_028b0b40c2a0428b28a6fda2e21d82ec613b4c32"
      }
    }
    stage('5-deploy-to-tomcat') {
    steps {
        withEnv(['WAR_FILE_PATH=~/workspace/maven-build/MavenEnterpriseApp-web/target/MavenEnterpriseApplication.war']) {
            sshagent(['tomcat']) {
                sh """
                scp -o StrictHostKeyChecking=no ${WAR_FILE_PATH} ubuntu@3.21.102.135:/opt/tomcat/apache-tomcat-9.0.88/webapps
                """
            }
        }
    }
}


  }
}
