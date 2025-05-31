NAMESPACE=dev

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install jenkins jenkins/jenkins \
  --version 5.8.53 \
  -n $NAMESPACE \
  --set controller.serviceType=NodePort \
  --set controller.service.nodePort=30080 \
  --set controller.containerPort=8080 \
  --set controller.resources.requests.memory=512Mi \
  --set controller.resources.requests.cpu=500m \
  --set controller.sidecars.configAutoReload.enabled=false \
  --set controller.initContainers="" \
  --set persistence.enabled=false

helm upgrade --install kafka bitnami/kafka \
  --version 32.2.8 \
  -n $NAMESPACE \
  --set kraft.enabled=true \
  --set zookeeper.enabled=false \
  --set controller.replicaCount=1 \
  --set persistence.enabled=false \
  --set resources.requests.memory=512Mi \
  --set resources.requests.cpu=500m \
  --set resources.limits.memory=1024Mi \
  --set resources.limits.cpu=1  \
  --set service.type=ClusterIP \
  --set listeners.client.protocol=PLAINTEXT \
  --set advertisedListeners[0].name=CLIENT \
  --set advertisedListeners[0].advertisedHost=kafka \
  --set advertisedListeners[0].advertisedPort=9092

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
