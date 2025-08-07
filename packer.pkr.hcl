variable "version" {
  type    = string
  default = "latest"
}

source "docker" "alpine" {
  commit = true
  image  = "alpine:latest"
  changes = [
    "CMD [\"/run.sh\"]"
  ]
}

build {
  sources = ["source.docker.alpine"]

  # Upgrade the software
  provisioner "shell" {
    inline = [
      "apk update",
      "apk upgrade",
    ]
  }

  # Install logrotate
  provisioner "shell" {
    inline = [
      "apk add --no-cache logrotate",
      "rm -rff /etc/logrotate.d",
    ]
  }

  # Add our example config
  provisioner "file" {
    source      = "logrotate.conf"
    destination = "/etc/logrotate.conf"
  }

  # Set the permissions and create the missing DIR
  provisioner "shell" {
    inline = [
      "chmod 0644 /etc/logrotate.conf",
      "mkdir /etc/logrotate.d",
    ]
  }

  # add our run script
  provisioner "file" {
    source      = "run.sh"
    destination = "/run.sh"
  }
  provisioner "shell" {
    inline = [
      "chmod 0755 /run.sh",
    ]
  }

  # Remove APK cache for space
  provisioner "shell" {
    inline = [
      "rm -rf /var/cache/apk/*",
    ]
  }

  post-processor "docker-tag" {
    repository = "akester/logrotate"
    tags = [
      "${var.version}",
      "alpine"
    ]
  }
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}
