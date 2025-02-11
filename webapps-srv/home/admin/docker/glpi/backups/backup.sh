#!/usr/bin/env bash
# Encoding : UTF-8
# Script to backup GLPI system files and database
# Add lines below to /etc/cron.d/backups on Host:
# 40 0 * * * admin /bin/bash -c "cd /home/admin/docker/glpi/; source .env && docker compose exec glpi /backups/backup.sh > /dev/null 2>&1"
# 45 0 * * * admin /bin/bash -c "cd /home/admin/docker/glpi/; source .env && docker compose exec glpi-mariadb /backups/backup.sh > /dev/null 2>&1"

# Constants
TODAY=$(date +"%Y-%m-%d")
BKP_DIR="/backups"

# Clean up backups files older than 1 day
find  ${BKP_DIR}/ -type f -mtime +1 -regextype posix-extended -regex '.*\.(backup\.tar\.bz2|sql-dump\.gz)$' -execdir rm -- '{}' \;

# Saved data depend on current container
if [[ "${HOSTNAME}" =~ ^.*glpi$ ]]; then
	# Backup system files
	cd ${APP_PATH}
	tar jcvf /backups/${TODAY}_${APP_NAME}_files.backup.tar.bz2 \
		./data \
		./config \
		./${APP_NAME}/plugins \
		./${APP_NAME}/marketplace
elif [[ "${HOSTNAME}" =~ ^.*mariadb$ ]]; then
	# Dump database
	cd ${BKP_DIR}
	mariadb-dump \
		--user root \
		--password=${MARIADB_ROOT_PASSWORD} \
		--all-databases | gzip > ${BKP_DIR}/${TODAY}_${APP_NAME}.sql-dump.gz
else
	echo 1>&2 "ERROR: ${HOSTNAME} don't match right container !";
	exit 1;
fi

# Set right permissions for Host
chown -R ${HOST_USER_ID}:${HOST_GROUP_ID} "${BKP_DIR}"
