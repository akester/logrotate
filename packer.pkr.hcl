variable "version" {
  type    = string
  default = "latest"
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
    repository = "akester/logrotate"
    tags       = [
      "${var.version}",
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
