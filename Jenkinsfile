pipeline {
  agent any

  tools {
    nodejs 'node'
  }

  options {
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        sh 'git rev-parse --abbrev-ref HEAD'
        sh 'node -v || true'
        sh 'npm -v || true'
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
          def image = (env.BRANCH_NAME == 'main') ? 'nodemain:v1.0' : 'nodedev:v1.0'
          def hostPort = (env.BRANCH_NAME == 'main') ? '3000' : '3001'
          def containerName = (env.BRANCH_NAME == 'main') ? 'app-main' : 'app-dev'

          sh """
            set -eux
            docker rm -f ${containerName} || true
            docker run -d --name ${containerName} --expose ${hostPort} -p ${hostPort}:3000 ${image}
            docker ps --filter "name=${containerName}"
            echo "Deployed ${env.BRANCH_NAME} => http://localhost:${hostPort}"
          """
        }
      }
    }
  }
}