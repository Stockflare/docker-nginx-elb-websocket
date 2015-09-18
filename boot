#!/usr/bin/env bash
SEP="==================="

confd -onetime -backend env

echo "Wrote nginx config..."
echo $SEP
cat /etc/nginx/nginx.conf
echo $SEP

nginx
