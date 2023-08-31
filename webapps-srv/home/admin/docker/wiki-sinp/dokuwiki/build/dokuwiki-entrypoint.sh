#!/bin/bash
set -e

# Copy Dokuwiki upgraded files into volume...
if [[ -d "/tmp/dokuwiki-${DW_VERSION}" ]]; then
	echo "/tmp/dokuwiki-${DW_VERSION} exists !"
	'cp' -af /tmp/dokuwiki-${DW_VERSION}/* ${HTML_PATH}/
	cd ${HTML_PATH}/
	grep -Ev '^($|#)' ${HTML_PATH}/data/deleted.files | xargs -n 1 rm -fr
	rm -fR /tmp/dokuwiki-${DW_VERSION}/
	chown -R www-data: ${HTML_PATH}
else
	echo "/tmp/dokuwiki-${DW_VERSION} NOT exists !"
fi

exec "$@"
