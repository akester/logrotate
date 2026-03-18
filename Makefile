IMAGE_NAME=akester/logrotate

build: init
	packer build .
	
init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-remote: login
	docker push $(IMAGE_NAME):amd64
	docker push $(IMAGE_NAME):arm64

push-manifest: push-remote
	docker manifest create $(IMAGE_NAME):latest $(IMAGE_NAME):amd64 $(IMAGE_NAME):arm64
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):arm64 --os linux --arch arm64
	docker manifest push $(IMAGE_NAME):latest
	