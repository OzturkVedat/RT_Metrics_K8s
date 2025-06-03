# Same base and root switch
FROM jenkins/jenkins:lts
USER root

# tools
RUN apt-get update && apt-get install -y \
    curl gnupg git bash apt-transport-https ca-certificates lsb-release software-properties-common

# kubectl
ENV KUBECTL_VERSION=v1.32.0
RUN curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# helm
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# docker cli
RUN curl -fsSL https://get.docker.com | bash

# plugins
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt
