NAMESPACE=dev

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kafka bitnami/kafka \
  --version 32.2.8 \
  -n $NAMESPACE \
  -f kafka-conf.yaml

helm upgrade --install pushgateway prometheus-community/prometheus-pushgateway \
  --namespace $NAMESPACE \
  --version 3.3.0 \
  --set service.type=NodePort \
  --set service.nodePort=30910 \
  --set resources.requests.memory=128Mi \
  --set resources.requests.cpu=100m

# build images into Minikube
eval $(minikube docker-env)
docker build -t producer:latest services/producer
docker build -t consumer:latest services/consumer

echo "Waiting for Kafka to be ready..."
kubectl wait --for=condition=Ready pod -n $NAMESPACE -l app.kubernetes.io/name=kafka --timeout=180s

echo "Creating topic if it doesn't exist..."
kubectl exec -n $NAMESPACE kafka-controller-0 -- \
  kafka-topics.sh \
    --bootstrap-server localhost:9092 \
    --create \
    --if-not-exists \
    --topic iot-sensor-data \
    --partitions 1 \
    --replication-factor 1

helm upgrade --install producer ./charts/producer -n $NAMESPACE 
helm upgrade --install consumer ./charts/consumer -n $NAMESPACE
