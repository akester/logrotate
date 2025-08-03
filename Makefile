build:
	packer init .
	packer build .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-local:
	docker push registry.gatewayks.net/akester/logrotate:latest
	docker push registry.gatewayks.net/akester/logrotate:debian12

push-remote: login
	docker push akester/logrotate:latest
	docker push akester/logrotate:debian12
