pipeline {
  agent any

  tools { 
    nodejs 'node' 
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

    stage('Deploy') {
      steps {
        script {
          def isMain = env.BRANCH_NAME == 'main'
          def image = isMain ? 'nodemain:v1.0' : 'nodedev:v1.0'
          def name = isMain ? 'app-main' : 'app-dev'
          def port = isMain ? '3000' : '3001'

          sh """
          docker rm -f ${name} || true
          docker run -d --name ${name} --expose ${port} -p ${port}:3000 ${image}
          """
        }
      }
    }
  }
}