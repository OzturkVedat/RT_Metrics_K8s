# To start minikube:

minikube start --driver=docker
eval $(minikube docker-env)

minikube status
kubectl get pods --namespace=dev

# To install Helm charts:

chmod +x deploy.sh
./deploy.sh

# RabbitMQ

minikube service rabbitmq -n dev
