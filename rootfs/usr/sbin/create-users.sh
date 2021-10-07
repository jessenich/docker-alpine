#!/usr/bin/env bash

apk add --update --no-cache bash

/bin/bash /usr/sbin/addsudouser.sh "$USER"

chown :sudo /usr/sbin/addsudouser.sh;
chmod 0770 /usr/sbin/addsudouser.sh;
