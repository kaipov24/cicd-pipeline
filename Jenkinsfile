pipeline {
  agent any

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git rev-parse --abbrev-ref HEAD'
      }
    }

    stage('Build') {
      steps {
        script {
          docker.image('node:7.8.0').inside {
            sh 'node -v'
            sh 'npm -v'
            sh 'npm install'
          }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          docker.image('node:7.8.0').inside {
            sh 'npm test'
          }
        }
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          if (env.BRANCH_NAME == 'main') {
            sh 'docker build -t nodemain:v1.0 .'
          } else if (env.BRANCH_NAME == 'dev') {
            sh 'docker build -t nodedev:v1.0 .'
          } else {
            error("Unsupported branch: ${env.BRANCH_NAME}")
          }
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          def isMain = (env.BRANCH_NAME == 'main')
          def image = isMain ? 'nodemain:v1.0' : 'nodedev:v1.0'
          def hostPort = isMain ? '3000' : '3001'
          def containerName = isMain ? 'app-main' : 'app-dev'

          sh """
            set -eux
            docker rm -f ${containerName} || true

            # run new container
            docker run -d --name ${containerName} --expose ${hostPort} -p ${hostPort}:3000 ${image}

            docker ps --filter "name=${containerName}"
            echo "Deployed ${env.BRANCH_NAME} => http://localhost:${hostPort}"
          """
        }
      }
    }
  }
}
