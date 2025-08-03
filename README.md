# Logrotate

This container is intended to run logrotate using a PVC against local log files.
Inspired by https://github.com/mkilchhofer/logrotate-container

## Tags

Just use `latest`.  It's based on Alpine and updated weekly to catch any
upstream changes and updates.

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

This is built using Packer.  If you haven't run `init`, do that first then you
can build.

```
packer init .
packer build .
```

## Mirror

If you're looking at this repo at https://github.com/akester/logrotate/, know
that it's a mirror of my local code repository.  This repo is monitored though,
so any pull requests or issues will be seen.
