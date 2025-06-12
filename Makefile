start:
	minikube start --driver=docker

status:
	minikube status

ports:
	kubectl get svc -n dev

context:
	kubectl config use-context minikube

pods:
	kubectl get pods --namespace=dev

deploy:
	chmod +x deploy.sh && ./deploy.sh
	
lint:
	helm lint charts/consumer

logs:
	kubectl logs consumer-58b74884cd-5rg8k -n dev


