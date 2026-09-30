// =====================================================================
// ISEC6000 Assessment 2 — CI/CD Pipeline
// Student ID : 23460810
// ---------------------------------------------------------------------
// Stages: Checkout -> Install -> Test -> Security Scan (FS)
//         -> Build Image -> Security Scan (Image) -> Push
// Agent : node:16 Docker image (per assignment requirement)
// Gate  : Trivy fails the build on HIGH/CRITICAL vulnerabilities
// ---------------------------------------------------------------------
// Key fixes in this version:
//   1. Trivy runs via `docker run` (not agent docker) so it can reach
//      the DinD daemon through the shared docker.sock
//   2. Image scan mounts /var/run/docker.sock so Trivy can inspect
//      the freshly-built image
//   3. Removed top-level post-condition archiveArtifacts (crashed
//      because agent none has no node context)
// =====================================================================
pipeline {
  agent none

  environment {
    REGISTRY        = 'docker.io'
    IMAGE_NAME      = 'harshavrdhan/isec6000-app'
    IMAGE_TAG       = "${env.BUILD_NUMBER}"
    DOCKER_HOST     = 'tcp://dind:2375'
    TRIVY_SEVERITY  = 'HIGH,CRITICAL'
    TRIVY_EXIT_CODE = '1'
  }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
    disableConcurrentBuilds()
    skipDefaultCheckout(true)
  }

  stages {

    stage('Checkout') {
      agent any
      steps {
        checkout scm
        sh 'ls -la'
      }
    }

    stage('Install Dependencies') {
      agent { docker { image 'node:16'; args '-u root' } }
      steps {
        sh 'npm install'
      }
    }

    stage('Run Unit Tests') {
      agent { docker { image 'node:16'; args '-u root' } }
      steps {
        sh 'npm test'
      }
    }

    stage('Security Scan (Filesystem)') {
      agent any
      steps {
        sh """
          docker run --rm \\
            -v \${WORKSPACE}:/workspace \\
            -w /workspace \\
            aquasec/trivy:latest fs \\
              --severity ${TRIVY_SEVERITY} \\
              --exit-code ${TRIVY_EXIT_CODE} \\
              --no-progress \\
              --format table \\
              --output trivy-fs.txt \\
              .
        """
      }
      post {
        always {
          archiveArtifacts artifacts: 'trivy-fs.txt', allowEmptyArchive: true
        }
      }
    }

    stage('Build Docker Image') {
      agent any
      steps {
        sh """
          docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .
        """
      }
    }

    stage('Security Scan (Image)') {
      agent any
      steps {
        sh """
          docker run --rm \\
            -v /var/run/docker.sock:/var/run/docker.sock \\
            -v \${WORKSPACE}:/workspace \\
            -w /workspace \\
            aquasec/trivy:latest image \\
              --severity ${TRIVY_SEVERITY} \\
              --exit-code ${TRIVY_EXIT_CODE} \\
              --no-progress \\
              --format table \\
              --output trivy-image.txt \\
              ${IMAGE_NAME}:${IMAGE_TAG}
        """
      }
      post {
        always {
          archiveArtifacts artifacts: 'trivy-image.txt', allowEmptyArchive: true
        }
      }
    }

    stage('Push to Registry') {
      agent any
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DH_USER',
          passwordVariable: 'DH_PASS'
        )]) {
          sh """
            echo "\$DH_PASS" | docker login -u "\$DH_USER" --password-stdin ${REGISTRY}
            docker push ${IMAGE_NAME}:${IMAGE_TAG}
            docker push ${IMAGE_NAME}:latest
            docker logout ${REGISTRY}
          """
        }
      }
    }
  }

  post {
    success { echo "Pipeline succeeded — build ${env.BUILD_NUMBER}" }
    failure { echo "Pipeline FAILED — check Trivy reports in artifacts" }
  }
}
