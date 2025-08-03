variable "version" {
  type    = string
  default = "latest"
}

source "docker" "debian12" {
  commit  = true
  image   = "debian:12"
}

build {
  sources = ["source.docker.debian12"]

  # Make sure the container is fully up to date
  provisioner "shell" {
    environment_vars = [
      "alpine_FRONTEND=noninteractive",
      "alpine_PRIORITY=critical"
    ]
    inline = [
      "set -e",
      "set -x",
      "apt-get update",
      "apt-get dist-upgrade -y",
    ]
    inline_shebang = "/bin/bash -e"
  }

  # Install logrotate
  provisioner "shell" {
    inline           = [
      "set -e",
      "set -x",
      "apt-get install -y logrotate",
      "rm -rff /etc/logrotate.d",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  # Add our example config
  provisioner "file" {
    source = "logrotate.conf"
    destination = "/etc/logrotate.conf"
  }

  # Set the permissions and create the missing DIR
  provisioner "shell" {
    inline           = [
      "set -e",
      "set -x",
      "chmod 0644 /etc/logrotate.conf",
      "mkdir /etc/logrotate.d",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline = [
      "set -e",
      "set -x",
      "rm -f /etc/apt/apt.conf.d/01proxy",
      "apt-get update",
      "apt-get autoremove",
      "apt-get clean",
    ]
    inline_shebang = "/bin/bash -e"
  }

  post-processor "docker-tag" {
    repository = "registry.gatewayks.net/akester/logrotate"
    tags       = [
      "${var.version}",
      "debian12"
    ]
  }

  post-processor "docker-tag" {
    repository = "akester/logrotate"
    tags       = [
      "${var.version}",
      "debian12"
    ]
  }
}

source "docker" "alpine" {
  commit  = true
  image   = "alpine:latest"
}

build {
  sources = ["source.docker.alpine"]

  # Install logrotate
  provisioner "shell" {
    inline           = [
      "apk update && apk add --no-cache logrotate",
      "rm -rff /etc/logrotate.d",
    ]
  }

  # Add our example config
  provisioner "file" {
    source = "logrotate.conf"
    destination = "/etc/logrotate.conf"
  }

  # Set the permissions and create the missing DIR
  provisioner "shell" {
    inline           = [
      "chmod 0644 /etc/logrotate.conf",
      "mkdir /etc/logrotate.d",
    ]
  }

  post-processor "docker-tag" {
    repository = "registry.gatewayks.net/akester/logrotate"
    tags       = [
      "alpine"
    ]
  }

  post-processor "docker-tag" {
    repository = "akester/logrotate"
    tags       = [
      "alpine"
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source = "github.com/hashicorp/docker"
    }
  }
}
