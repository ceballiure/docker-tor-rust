#!/bin/bash

docker build -t tor:$1 --build-arg TOR_BRANCH=tor-$1 . 
