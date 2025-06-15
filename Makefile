NAMESPACE=dev
KAFKA_POD := $(shell kubectl get pods -n $(NAMESPACE) -l app.kubernetes.io/name=kafka -o jsonpath="{.items[0].metadata.name}")
PRODUCER_POD := $(shell kubectl get pod -n $(NAMESPACE) -l app.kubernetes.io/name=producer -o jsonpath="{.items[0].metadata.name}")
CONSUMER_POD := $(shell kubectl get pod -n $(NAMESPACE) -l app.kubernetes.io/name=consumer -o jsonpath="{.items[0].metadata.name}")

start:
	minikube start --driver=docker

resource:
	@minikube config set cpus 4
	@minikube config set memory 6144

status:
	minikube status

ports:
	kubectl get svc -n $(NAMESPACE)

context:
	kubectl config use-context minikube

pods:
	kubectl get pods --namespace=$(NAMESPACE)

deploy:
	chmod +x deploy.sh && ./deploy.sh

redeploy:
	@minikube delete && make start && make deploy

lint:
	helm lint charts/consumer

k-logs:
	kubectl logs $(KAFKA_POD) -n $(NAMESPACE) --tail=50

topics:
	@kubectl exec -n $(NAMESPACE) $(KAFKA_POD) -- \
	kafka-topics.sh --bootstrap-server localhost:9092 --list

partitions:
	@kubectl exec -n $(NAMESPACE) $(KAFKA_POD) -- \
	kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic iot-sensor-data

consume-kafka:
	@echo "Consuming messages from topic..."
	@kubectl exec -n $(NAMESPACE) -it $(KAFKA_POD) -- \
	kafka-console-consumer.sh \
		--bootstrap-server localhost:9092 \
		--topic iot-sensor-data \
		--from-beginning \
		--timeout-ms 10000 \
		--group debug-consumer-$$RANDOM

c-logs:
	@kubectl logs $(CONSUMER_POD) -n $(NAMESPACE) --tail=50

c-connection:
	@kubectl exec -n $(NAMESPACE) -it $(CONSUMER_POD) -- \
	wget --spider kafka.dev.svc.cluster.local:9092

p-logs:
	@kubectl logs $(PRODUCER_POD) -n $(NAMESPACE) --tail=50