IMAGE_NAME := jenkins-with-kubectl
CONTAINER_NAME := jenkins
HOST_KUBECONFIG := $$HOME/.kube

.PHONY: build run stop rm logs rebuild

build:
	docker build -t $(IMAGE_NAME) .

run:
	docker run -d \
		--name $(CONTAINER_NAME) \
		-u root \
		-p 8080:8080 \
		-p 50000:50000 \
		-v jenkins_home:/var/jenkins_home \
		-v $(HOST_KUBECONFIG):/root/.kube \
		-v /var/run/docker.sock:/var/run/docker.sock \
		$(IMAGE_NAME)

stop:
	docker stop $(CONTAINER_NAME)

rm:
	docker rm -f $(CONTAINER_NAME)

logs:
	docker logs -f $(CONTAINER_NAME)

rebuild: rm build run
