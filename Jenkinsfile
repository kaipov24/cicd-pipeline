pipeline {
  agent any

  environment {
    PATH = "/var/lib/jenkins/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/node/bin:${env.PATH}"
  }

  options {
    skipDefaultCheckout(true)
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build') {
      steps {
        sh 'npm install'
      }
    }

    stage('Test') {
      steps {
        sh 'npm test'
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          if (env.BRANCH_NAME == 'main') {
            sh 'docker build -t nodemain:v1.0 .'
          } else {
            sh 'docker build -t nodedev:v1.0 .'
          }
        }
      }
    }

    stage('Trivy scan') {
      steps {
        script {
          def image = (env.BRANCH_NAME == 'main') ? 'nodemain:v1.0' : 'nodedev:v1.0'
          sh "trivy image --no-progress --severity HIGH,CRITICAL ${image}"
        }
      }
    }

    stage('Push to DockerHub') {
      steps {
        script {
          def isMain = env.BRANCH_NAME == 'main'
          def localImage = isMain ? 'nodemain:v1.0' : 'nodedev:v1.0'
          def remoteImage = isMain ? 'kairatkaipov/cicd-pipeline:nodemain-v1.0'
                                    : 'kairatkaipov/cicd-pipeline:nodedev-v1.0'


          withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
            sh """
              set -eux
              echo \$PASS | docker login -u \$USER --password-stdin https://index.docker.io/v1/
              docker tag ${localImage} ${remoteImage}
              docker push ${remoteImage}
              docker logout https://index.docker.io/v1/
            """
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          def isMain = env.BRANCH_NAME == 'main'
          def image = isMain ? 'nodemain:v1.0' : 'nodedev:v1.0'
          def containerName = isMain ? 'app-main' : 'app-dev'
          def port = isMain ? '3000' : '3001'

          sh """
            set -eux
            docker rm -f ${containerName} || true
            docker run -d --name ${containerName} --expose ${port} -p ${port}:3000 ${image}
            docker ps --filter "name=${containerName}"
          """
        }
      }
    }
    stage('Trigger single pipeline deploy main/dev') {
      steps {
        script {
          if (env.BRANCH_NAME == 'main') {
            build job: 'Deploy_to_main', wait: false
          } else if (env.BRANCH_NAME == 'dev') {
            build job: 'Deploy_to_dev', wait: false
          }
        }
      }
    }
  }
}