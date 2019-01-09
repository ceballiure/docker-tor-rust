#!/bin/bash

IMAGE=tor:$1
result=$( docker inspect $IMAGE )

if [ $? -ne 0 ]; then
  echo "Target image $IMAGE does not exits. You can create it with create_image.sh"
  exit
fi

TORRC_ABSOLUTE=$(readlink -f $2)
if [[ ! -s $TORRC_ABSOLUTE ]] ; then
  echo "Target torrc file does not exist"
  exit
fi

VOLUME_ABSOLUTE=$(readlink -f $3)
if [[ ! -d $VOLUME_ABSOLUTE ]]; then
  echo "You need to provide a shared folder on the host in order to save the tor relay state. Note that this folder will contain the private keys of the relay"
  exit
fi

RANDOM_STR=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | head -n 1)
DEFAULT_NAME=torrelay-$RANDOM_STR
CONTAINER_NAME=${4:-$DEFAULT_NAME}

docker run --name $CONTAINER_NAME \
 --restart always \
 -d \
 -p 9001:9001 \
 -v $TORRC_ABSOLUTE:/etc/tor/torrc \
 -v $VOLUME_ABSOLUTE:/home/tor/.tor tor:$1 \
 tor -f /etc/tor/torrc

echo "Running container with name $CONTAINER_NAME and image $IMAGE"
