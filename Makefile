build: init
	packer build .
	
init:
	packer init .

debian12: init
	packer build -only=docker.debian12 . 

alpine: init
	packer build -only=docker.alpine . 

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-local:
	docker push registry.gatewayks.net/akester/logrotate:latest
	docker push registry.gatewayks.net/akester/logrotate:debian12
	docker push registry.gatewayks.net/akester/logrotate:alpine

push-remote: login
	docker push akester/logrotate:latest
	docker push akester/logrotate:debian12
	docker push akester/logrotate:alpine
