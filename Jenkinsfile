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
    stage('4-codequality'){
        steps{
       sh "mvn clean verify sonar:sonar \
  -Dsonar.projectKey=team9 \
  -Dsonar.host.url=http://52.14.168.43:9000 \
  -Dsonar.login=sqp_cd04b953d15f86fd96f9ac31a3edce2a6de2fe36"
      }
    }
     stage('5-deploy-to-tomcat'){
         steps{
             sshagent(['tomcat']) {
               sh """
              scp -o StrictHostKeyChecking=no ~/workspace/maven/MavenEnterpriseApp-web/target/MavenEnterpriseApplication.war ubuntu@18.189.186.73:/opt/tomcat/apache-tomcat-9.0.88/webapps
               """
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
            to: 'nfor.rudolph1@gmail.com'
        }
    }
  }
}
