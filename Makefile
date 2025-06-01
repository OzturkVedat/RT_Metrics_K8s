start:
	minikube start --driver=docker

status:
	minikube status

ports:
	kubectl get svc -n dev

use-context:
	kubectl config use-context minikube

pods:
	kubectl get pods --namespace=dev

deploy:
	chmod +x deploy.sh && ./deploy.sh
	
lint:
	helm lint charts/consumer

logs:
	kubectl logs consumer-58b74884cd-c2c5x -n dev

metrics:
	curl http://192.168.49.2:30155/metrics	

