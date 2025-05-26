NAMESPACE=dev

kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# install kafka (with kraft mode and persistence disabled)
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

# install rabbitmq (persistence disabled, resource limits set)
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

helm upgrade --install producer ./charts/producer \
  -n $NAMESPACE
