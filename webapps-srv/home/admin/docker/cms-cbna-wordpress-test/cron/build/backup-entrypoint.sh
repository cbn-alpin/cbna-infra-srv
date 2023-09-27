#!/bin/sh
set -e

# Create environment file to use in cron.d scripts
printenv | sed 's/=\(.*\)/="\1"/' > /etc/environment

# Start cron IN foreground mode, don't daemonize.
/usr/sbin/cron -f
