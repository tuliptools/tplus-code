#!/bin/bash

mkdir /run/haproxy/ && /usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -D -p /tmp/haproxy.pid &

sudo -H -u coder /usr/local/bin/code-server --host 0.0.0.0
