IMAGE_NAME := jenkins-with-kubectl
CONTAINER_NAME := jenkins

.PHONY: build run stop rm logs rebuild


build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-u root \
		-p 8080:8080 \
		-v jenkins_home:/var/jenkins_home \
		-v /mnt/c/Users/user/.kube:/root/.kube \
		-v /mnt/c/Users/user/.minikube:/root/.minikube \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-e MINIKUBE_HOME=/root \
		-e JAVA_OPTS=-Djenkins.install.runSetupWizard=false \
		$(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)

rm:
	docker rm -f $(CONTAINER_NAME)

logs:
	docker logs -f $(CONTAINER_NAME)

rebuild: rm build run
