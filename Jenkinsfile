@Library('JenkinsTesLib') _

pipeline {
  agent any

  tools {
    nodejs 'node'
  }

  environment {
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
        sh 'npm test -- --watchAll=false'
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
          def localImage = ci.dockerTagForBranch(env.BRANCH_NAME)
          sh "docker build -t ${localImage} ."
        }
      }
    }

    stage('Trivy scan') {
      steps {
        script {
          def image = ci.dockerTagForBranch(env.BRANCH_NAME)
          ci.trivyScan(image)
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

// pipeline {
//   agent any

//   options {
//     timestamps()
//   }

//   stages {
//     stage('Deploy') {
//       steps {
//         script {

//           def image = (params.ENV == 'main')
//             ? "kairatkaipov/cicd-pipeline:nodemain-${params.TAG}"
//             : "kairatkaipov/cicd-pipeline:nodedev-${params.TAG}"

//           def container = (params.ENV == 'main') ? "app-main" : "app-dev"
//           def port = (params.ENV == 'main') ? "3000" : "3001"

//           sh """
//             set -eux
//             docker pull ${image}
//             docker rm -f ${container} || true
//             docker run -d --name ${container} -p ${port}:3000 ${image}
//             docker ps --filter name=${container}
//             echo "Deployed ${params.ENV} on port ${port}"
//           """
//         }
//       }
//     }
//   }
// }
