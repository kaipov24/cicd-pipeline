pipeline {
  agent any

  tools {
    nodejs 'node'
  }

  options {
    timestamps()
    disableConcurrentBuilds()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        echo "BRANCH_NAME=${env.BRANCH_NAME}"
      }
    }

    stage('Build') {
      steps {
        sh 'node -v'
        sh 'npm -v'
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
          def containerName = isMain ? 'app-main' : 'app-dev'

          sh """
            set -eux
            docker rm -f ${containerName} || true

            ${isMain ?
              "docker run -d --name ${containerName} --expose 3000 -p 3000:3000 ${image}" :
              "docker run -d --name ${containerName} --expose 3001 -p 3001:3000 ${image}"
            }

            docker ps --filter "name=${containerName}"
          """
        }
      }
    }
  }
}