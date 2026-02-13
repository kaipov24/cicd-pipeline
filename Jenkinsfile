@Library('shared-lib') _

pipeline {
  agent any

  environment {
    PATH = "/var/lib/jenkins/tools/jenkins.plugins.nodejs.tools.NodeJSInstallation/node/bin:${env.PATH}"
    TRIVY_CACHE_DIR = "/var/lib/jenkins/trivy-cache"
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

    stage('Hadolint') {
      steps {
        script { ci.hadolint() }
      }
    }

    stage('Build Docker image') {
      steps {
        script {
          def tag = ci.dockerTagForBranch(env.BRANCH_NAME) 
          sh "docker build -t ${tag} ."
        }
      }
    }

    stage('Trivy scan') {
      steps {
        script {
          def tag = ci.dockerTagForBranch(env.BRANCH_NAME)
          ci.trivyScan(tag)
        }
      }
    }

    stage('Push to DockerHub') {
      steps {
        script {
          def localImage  = ci.dockerTagForBranch(env.BRANCH_NAME)
          def remoteImage = ci.dockerRemoteForBranch(env.BRANCH_NAME)
          ci.pushImage(localImage, remoteImage, 'dockerhub')
        }
      }
    }

    stage('Deploy') {
      steps {
        script {
          def localImage = ci.dockerTagForBranch(env.BRANCH_NAME)
          ci.deploy(env.BRANCH_NAME, localImage)
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