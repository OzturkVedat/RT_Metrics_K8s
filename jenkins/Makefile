# use wsl

IMAGE_NAME := jenkins-with-kubectl
CONTAINER_NAME := jenkins

KUBE_CONFIG_WIN := /mnt/c/Users/user/.kube/config
KUBE_CONFIG_LN := .kube/config

.PHONY: build run stop rm logs rebuild patch-kubeconfig


build:
	docker build -t $(IMAGE_NAME) .

patch-kubeconfig:
	@echo "Patching kube config for Linux paths..."
	@mkdir -p .kube
	@cat $(KUBE_CONFIG_WIN) \
	| sed 's|C:\\\\Users\\\\user|/root|g' \
	| sed 's|\\|/|g' \
	| sed 's|C:/Users/user|/root|g' \
	> $(KUBE_CONFIG_LN)

run: patch-kubeconfig
	docker run -d \
		--name $(CONTAINER_NAME) \
		-u root \
		-p 8080:8080 \
		-v jenkins_home:/var/jenkins_home \
		-v $(PWD)/.kube/config:/root/.kube/config:ro \
		-v /mnt/c/Users/user/.minikube:/root/.minikube \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e JAVA_OPTS=-Djenkins.install.runSetupWizard=false \
		$(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)

rm:
	docker rm -f $(CONTAINER_NAME)
	rm -f $(KUBE_CONFIG_LN)

logs:
	docker logs -f $(CONTAINER_NAME)

rebuild: rm build run
