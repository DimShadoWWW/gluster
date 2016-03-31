#!/bin/bash

ETCD_ADDRESS=$(ip route list match 0/0 | awk '/default/ { print $3 }')

if [ "${1#-}" != "$1" ]; then
	set -- confd "$@"
fi

if [ "$1" = 'confd' ]; then
	shift
	set -- confd -node "$ETCD_ADDRESS" "$@"
  echo "Starting confd with command '$@'"
  exec "$@"
else
  echo "Executing '$@'"
  exec "$@"
fi
