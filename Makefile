start:
	minikube start --driver=docker

resource:
	@minikube config set cpus 4
	@minikube config set memory 6144

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

redeploy:
	@minikube delete && make start && make deploy

lint:
	helm lint charts/consumer

k-logs:
	kubectl logs kafka-controller-0 -n dev --tail=50

topics:
	kubectl exec -n dev kafka-controller-0 -- \
  	kafka-topics.sh --bootstrap-server localhost:9092 --list

partitions:
	kubectl exec -n dev kafka-controller-0 -- \
  	kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic iot-sensor-data

c-logs:
	kubectl logs $$(kubectl get pod -n dev -l app.kubernetes.io/name=consumer -o jsonpath="{.items[0].metadata.name}") -n dev --tail=50

c-connection:
	kubectl exec -n dev -it $$(kubectl get pod -n dev -l app.kubernetes.io/name=consumer -o jsonpath="{.items[0].metadata.name}") -- wget --spider kafka.dev.svc.cluster.local:9092

p-logs:
	kubectl logs $$(kubectl get pod -n dev -l app.kubernetes.io/name=producer -o jsonpath="{.items[0].metadata.name}") -n dev --tail=50
