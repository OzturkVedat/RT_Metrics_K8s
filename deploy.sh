NAMESPACE=dev

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kafka bitnami/kafka \
  --version 32.2.8 \
  -n dev \
  --set kraft.enabled=true \
  --set zookeeper.enabled=false \
  --set controller.replicaCount=1 \
  --set service.type=ClusterIP \
  --set listeners.client.protocol=PLAINTEXT \
  --set advertisedListeners[0].name=PLAINTEXT \
  --set advertisedListeners[0].advertisedHost=kafka.dev.svc.cluster.local \
  --set advertisedListeners[0].advertisedPort=9092 \
  --set extraEnvVars[0].name=KAFKA_CFG_LISTENERS \
  --set extraEnvVars[0].value=PLAINTEXT://0.0.0.0:9092 \
  --set configurationOverrides["offsets.topic.replication.factor"]=1 \
  --set configurationOverrides["transaction.state.log.replication.factor"]=1 \
  --set configurationOverrides["transaction.state.log.min.isr"]=1

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

helm upgrade --install producer ./charts/producer -n $NAMESPACE 
helm upgrade --install consumer ./charts/consumer -n $NAMESPACE
