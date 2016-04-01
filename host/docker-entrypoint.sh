#!/bin/bash

ETCD_ADDRESS=$(ip route list match 0/0 | awk '/default/ { print $3 }')
[ -z "$GLUSTER_VOLUME_NAME" ] && echo "The environment variable GLUSTER_VOLUME_NAME must be set" && exit 1;
[ -z "$GLUSTER_PRIVATE_IP" ] && echo "The environment variable GLUSTER_PRIVATE_IP must be set" && exit 1;
[ -z "$GLUSTER_REPLICATION" ] && echo "The environment variable GLUSTER_REPLICATION must be set" && exit 1;
[ -z "$GLUSTER_LOCATION" ] && echo "The environment variable GLUSTER_LOCATION must be set" && exit 1;
HOSTNAME=$(cat /etc/hostname)

echo "Setting etcd key /services/gluster/$GLUSTER_VOLUME_NAME/machines/$HOSTNAME to $GLUSTER_PRIVATE_IP"
curl -L http://$ETCD_ADDRESS:2379/v2/keys/services/gluster/$GLUSTER_VOLUME_NAME/machines/$HOSTNAME -XPUT -d value="$GLUSTER_PRIVATE_IP" 2> /dev/null
echo "Setting etcd key /services/gluster/$GLUSTER_VOLUME_NAME/storage/$HOSTNAME to $GLUSTER_LOCATION"
curl -L http://$ETCD_ADDRESS:2379/v2/keys/services/gluster/$GLUSTER_VOLUME_NAME/storage/$HOSTNAME -XPUT -d value="$GLUSTER_LOCATION" 2> /dev/null
echo "Setting up hosts file for first time"
until confd -backend etcd -onetime -node $ETCD_ADDRESS:2379 -prefix /services/gluster/$GLUSTER_VOLUME_NAME; do
    echo "Waiting for confd to create initial hosts file"
    sleep 2
done
echo "Getting list of machines in etcd for /services/gluster/$GLUSTER_VOLUME_NAME"
GLUSTER_MACHINES=$(curl -L http://$ETCD_ADDRESS:2379/v2/keys/services/gluster/$GLUSTER_VOLUME_NAME/machines 2> /dev/null | python -c 'import json,sys;obj=json.load(sys.stdin);print " ".join(map(lambda x: x["key"].split("/")[-1], obj["node"]["nodes"]))')
echo "Starting glusterd service"
/usr/sbin/glusterd -p /var/run/glusterd.pid

GLUSTER_MACHINES_STORAGE="$HOSTNAME:$GLUSTER_LOCATION"

for GLUSTER_MACHINE in "${GLUSTER_MACHINES[@]}"; do
	if [ "$GLUSTER_MACHINE" -ne "$HOSTNAME" ]; then
		# For each host apart from this one
		echo "Running gluster peer probe for $GLUSTER_MACHINE"
		[ gluster peer probe $GLUSTER_MACHINE ] || echo "Could not contact $GLUSTER_MACHINE" && CREATE_GLUSTER_VOLUME=false
    GLUSTER_MACHINES_STORAGE="$GLUSTER_MACHINES_STORAGE $GLUSTER_MACHINE:$(curl -L http://$ETCD_ADDRESS:2379/v2/keys/services/gluster/$GLUSTER_VOLUME_NAME/storage/$GLUSTER_MACHINE 2> /dev/null | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["node"]["value"]))')"
	fi
done

if gluster peer status | grep "Disconnected" > /dev/null; then
	echo "One of the gluster peers is disconnected."
	CREATE_GLUSTER_VOLUME=false
fi

if [ $CREATE_GLUSTER_VOLUME = true ]; then
	if gluster volume list |& grep "No volumes present in cluster" > /dev/null; then
    echo "Creating gluster volume $GLUSTER_VOLUME_NAME"
    gluster volume create $GLUSTER_VOLUME_NAME transport tcp replica $GLUSTER_REPLICATION $GLUSTER_MACHINES_STORAGE
    echo "Starting gluster volume $GLUSTER_VOLUME_NAME"
    gluster volume start $GLUSTER_VOLUME_NAME
	fi
fi

if [ "${1#-}" != "$1" ]; then
	set -- confd "$@"
fi

if [ "$1" = 'confd' ]; then
	shift
	set -- confd -backend etcd -watch -node $ETCD_ADDRESS:2379 -prefix /services/gluster/$GLUSTER_VOLUME_NAME "$@"
  echo "Starting confd with command '$@'"
  exec "$@"
else
  echo "Executing '$@'"
  exec "$@"
fi
