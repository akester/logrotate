#!/bin/sh

set -e
set -x

STATE="${STATE_FILE_PATH:-/var/log/app/logrotate.state}"

logrotate -v -s "$STATE" /etc/logrotate.conf
