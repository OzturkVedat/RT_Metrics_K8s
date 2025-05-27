# minikube

minikube start --driver=docker
minikube status

kubectl config use-context minikube
kubectl get pods --namespace=dev
kubectl describe pod xxxxx -n dev

# To install Helm charts:

chmod +x deploy.sh
./deploy.sh

# Helm

helm lint charts/producer

# RabbitMQ

minikube service rabbitmq -n dev
