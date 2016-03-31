#!/bin/bash

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- glusterd "$@"
fi

if [ "$1" = 'glusterd' ]; then
	shift
	set -- glusterd -p /run/glusterd.pid "$@"
  echo "Starting glusterd with command '$@'"
  exec "$@"
else
  echo "Executing '$@'"
  exec "$@"
fi
