pipeline {
    agent any

    environment {
        IMAGE_NAME = 'producer'
        IMAGE_TAG = 'latest'
        DOCKERFILE_PATH = 'services/producer'
        CHART_PATH = 'charts/producer'
        RELEASE_NAME = 'producer'
        NAMESPACE = 'dev'
    }

    stages {
        stage('Verify Tools') {
            steps {
                sh 'docker --version'
                sh 'minikube version'
                sh 'kubectl version --client'
                sh 'helm version'
            }
        }

        stage('Create Namespace') {
            steps {
                sh "kubectl get namespace ${NAMESPACE} || kubectl create namespace ${NAMESPACE}"
            }
        }

        stage('Build Image Locally') {
            steps {
                echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}"
            }
        }

        stage('Load Image to Minikube') {
            steps {
                echo 'Loading image to Minikube..'
                sh "minikube image load ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }

        stage('Deploy with Helm') {
            steps {
                echo 'Deploying with Helm...'
                sh """
                helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \
                  --namespace ${NAMESPACE} \
                  --set image.repository=${IMAGE_NAME} \
                  --set image.tag=${IMAGE_TAG} \
                  --set image.pullPolicy=IfNotPresent
                """
            }
        }

        stage('Check Deployment') {
            steps {
                sh "kubectl rollout status deployment/${RELEASE_NAME} -n ${NAMESPACE} --timeout=60s"
            }
        }
    }
}
