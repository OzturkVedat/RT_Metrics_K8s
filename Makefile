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

k-logs:
	kubectl logs kafka-controller-0 -n dev --tail=50

consumer-conn:
	kubectl exec -n dev -it consumer-58b74884cd-4xxn4 -- wget --spider kafka.dev.svc.cluster.local:9092


