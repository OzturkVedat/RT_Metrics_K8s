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
        stage('Show Versions') {
            steps {
                sh 'docker --version'
                sh 'kubectl version --short'
                sh 'helm version'
            }
        }

        stage('Checkout Code'){
            steps{
                git url: 'https://github.com/OzturkVedat/RT_Metrics_K8s.git', branch: 'main'
            }
        }

        stage('Ensure Namespace') {
            steps {
                sh "kubectl get namespace ${NAMESPACE} || kubectl create namespace ${NAMESPACE}"
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERFILE_PATH}"
            }
        }

        stage('Deploy with Helm') {
            steps {
                sh """
                helm upgrade --install ${RELEASE_NAME} ${CHART_PATH} \
                  --namespace ${NAMESPACE} \
                  --set image.repository=${IMAGE_NAME} \
                  --set image.tag=${IMAGE_TAG} \
                  --set image.pullPolicy=IfNotPresent
                """
            }
        }

        stage('Check Rollout') {
            steps {
                sh "kubectl rollout status deployment/${RELEASE_NAME} -n ${NAMESPACE} --timeout=60s"
            }
        }
    }
}
