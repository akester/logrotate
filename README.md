# Logrotate

This container is intended to run logrotate using a PVC against local log files.
Inspired by https://github.com/mkilchhofer/logrotate-container

## Tags

Just use `latest`.  It's based on Alpine and updated weekly to catch any
upstream changes and updates.

## Config

This accepts a single environment variable, `STATE_FILE_PATH`, for a state file
created by logrotate.  It's best if this is stored on a volume that will survive
the container restarting.

By default this is in `/var/log/app/logrotate.state`, but it can be set anywhere
(or discarded and state won't be saved).

## Example Usage

Define the logrotate config itself:

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: logrotate-config
data:
  my_logs.conf: |
    /var/log/app/*.log {
        daily
        missingok
        rotate 7
        compress
        delaycompress
        dateformat -%Y%m%d_%H%M%S
        notifempty
        copytruncate
        su
    }
  my_txt_logs.conf: |
    /var/log/app/*.txt {
        daily
        missingok
        rotate 3
        compress
        delaycompress
        dateformat -%Y%m%d_%H%M%S
        notifempty
        copytruncate
        su
    }
```

Then define a cron to run this container with that config:

```
---
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: app-logrotate
spec:
  schedule: "*/1 * * * *"
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: logrotate
            image: akester/logrotate
            volumeMounts:
            - name: logrotate-conf
              mountPath: /etc/logrotate.d
            - name: app-logs
              mountPath: /var/log/app
          volumes:
          - name: logrotate-conf
            configMap:
              name: logrotate-config
          - name: app-logs
            persistentVolumeClaim:
              claimName: app-logs-pv
          restartPolicy: OnFailure
```

## Development

The container is built using Packer and has a Makefile, just run `make` to start
a build.

## Mirror

If you're looking at this repo at https://github.com/akester/logrotate/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.
