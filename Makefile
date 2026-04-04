IMAGE_NAME=akester/logrotate

build-x86: init
	packer build --only=docker.alpine-amd64 .

build-arm: init
	packer build --only=docker.alpine-arm64 .

push-x86: login
	docker push $(IMAGE_NAME):alpine-amd64

push-arm: login
	docker push $(IMAGE_NAME):alpine-arm64
	
init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-manifest: login
	docker manifest create $(IMAGE_NAME):latest $(IMAGE_NAME):alpine-amd64 $(IMAGE_NAME):alpine-arm64
	docker manifest annotate $(IMAGE_NAME):latest $(IMAGE_NAME):alpine-arm64 --os linux --arch arm64
	docker manifest push --purge $(IMAGE_NAME):latest
