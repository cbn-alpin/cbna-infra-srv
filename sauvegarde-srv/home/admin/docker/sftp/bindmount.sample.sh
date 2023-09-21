#!/bin/bash
# File mounted as: /etc/sftp.d/bindmount.sh

function bindmount() {
    if [ -d "${1}" ]; then
        mkdir -p "${2}"
    fi
    mount --bind ${3} "${1}" "${2}"
}

# Remember permissions, you may have to fix them:
# chown -R :users /data/data

bindmount /data/data /home/data
bindmount /data/data /home/data-reader --read-only
bindmount /data/partner /home/partner
