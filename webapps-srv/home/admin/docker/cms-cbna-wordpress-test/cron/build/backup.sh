#!/usr/bin/env bash
# Encoding : UTF-8
# Script to backup Wordpress database and wp-content directory

TODAY=$(date +"%Y-%m-%d")
BKP_DIR="/backups"

mariadb-dump --host cms-cbna-test-mariadb --port 3306 \
	--user root --password=${MARIADB_ROOT_PASSWORD} \
	--all-databases > ${BKP_DIR}/${TODAY}_cms-cbna_wordpress.dump.sql

tar -jcvf "${BKP_DIR}/${TODAY}_cms-cbna_wp-content.backup.tar.bz2" /var/www/html/wp-content

chown -R ${HOST_USER_ID}:${HOST_GROUP_ID} "${BKP_DIR}"

find "${BKP_DIR}/" -type f -mtime +1 -regextype egrep -regex '.*\.(backup\.tar\.bz2|dump\.sql)$' -exec rm {} \;

for filename in "${BKP_DIR}/*" ; do
	echo $filename
done;
