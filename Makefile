build: init
	packer build .
	
init:
	packer init .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-remote: login
	docker push akester/logrotate:latest
	docker push akester/logrotate:debian12
	docker push akester/logrotate:alpine
