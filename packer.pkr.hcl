variable "version" {
  type    = string
  default = "latest"
}

source "docker" "debian" {
  commit  = true
  image   = "debian:12"
}

build {
  sources = ["source.docker.debian"]

  # Example for running some installs
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "DEBIAN_PRIORITY=critical"
    ]
    inline           = [
      "set -e",
      "set -x",
      "apt-get -y install wget",
      "wget https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64 -O /usr/local/bin/sops",
      "chmod +x /usr/local/bin/sops",
      "chmod a+r /etc/age-key.txt",
    ]
    inline_shebang   = "/bin/bash -e"
  }

  post-processor "docker-tag" {
    repository = "registry.gatewayks.net/containername"
    tags       = [
      "${var.version}"
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
