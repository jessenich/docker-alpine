#!/usr/bin/env bash

apk add --update --no-cache bash

/bin/bash /usr/sbin/addsudouser.sh "$1"
