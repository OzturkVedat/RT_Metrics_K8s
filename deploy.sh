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
  --set resources.limits.cpu=1

helm upgrade --install rabbitmq bitnami/rabbitmq \
  --version 16.0.3 \
  -n $NAMESPACE \
  --set auth.username=guest \
  --set auth.password=guest \
  --set auth.erlangCookie=secretcookie \
  --set persistence.enabled=false \
  --set resources.requests.memory=256Mi \
  --set resources.requests.cpu=250m \
  --set resources.limits.memory=512Mi \
  --set resources.limits.cpu=500m

# build producer image into Minikube
eval $(minikube docker-env)
docker build -t producer:latest services/producer

helm upgrade --install producer ./charts/producer -n $NAMESPACE 

