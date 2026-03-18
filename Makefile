IMAGE_NAME=akester/logrotate

build: init
	packer build .
	
init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-tags: login
	docker push $(IMAGE_NAME):alpine-amd64
	docker push $(IMAGE_NAME):alpine-arm64

push-remote: push-tags
	docker manifest create $(IMAGE_NAME):latest $(IMAGE_NAME):alpine-amd64 $(IMAGE_NAME):alpine-arm64
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):alpine-arm64 --os linux --arch arm64
	docker manifest push $(IMAGE_NAME):latest
