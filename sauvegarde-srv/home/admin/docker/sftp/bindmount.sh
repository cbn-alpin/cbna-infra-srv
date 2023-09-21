#!/bin/bash
# File mounted as: /etc/sftp.d/bindmount.sh

function bindmount() {
    if [ -d "$1" ]; then
        mkdir -p "$2"
    fi
    mount --bind $3 "$1" "$2"
}

# Remember permissions, you may have to fix them:
# chown -R :users /data/common

bindmount /data /home/data
bindmount /data /home/data-reader --read-only
bindmount /data/cd26 /home/cd26
bindmount /data/cbnmed /home/cbnmed
