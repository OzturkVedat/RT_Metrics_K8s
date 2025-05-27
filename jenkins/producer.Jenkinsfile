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
        stage('Run Pipeline from Local Project Folder') {
            steps {
                dir('/workspace') {
                    script {
                        sh 'docker --version'
                        sh 'minikube version'
                        sh 'kubectl version --client'
                        sh 'helm version'

                        sh "kubectl get namespace ${NAMESPACE} || kubectl create namespace ${NAMESPACE}"

                        echo "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                        sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}"

                        echo 'Loading image to Minikube..'
                        sh "minikube image load ${IMAGE_NAME}:${IMAGE_TAG}"

                        echo 'Deploying with Helm...'
                        sh """
                        helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \
                          --namespace ${NAMESPACE} \
                          --set image.repository=${IMAGE_NAME} \
                          --set image.tag=${IMAGE_TAG} \
                          --set image.pullPolicy=IfNotPresent
                        """

                        sh "kubectl rollout status deployment/${RELEASE_NAME} -n ${NAMESPACE} --timeout=60s"
                    }
                }
            }
        }
    }
}
