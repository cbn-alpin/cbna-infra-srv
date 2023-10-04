#!/bin/bash
# Copy App upgraded files into volume...
set -e

if [[ -d ${APP_PATH}/${APP_NAME}/install/ ]] && [[ -f ${APP_PATH}/${APP_NAME}/version/${APP_VERSION} ]]; then
	echo "First install !"
	cd /tmp

	echo "Install database..."
	set +e
	php ${APP_PATH}/${APP_NAME}/bin/console system:check_requirements
	set -e
	php ${APP_PATH}/${APP_NAME}/bin/console db:install \
		--db-host=${DB_HOST} \
		--db-name=${DB_NAME} \
		--db-user=${DB_USER} \
		--db-password=${DB_PASSWORD} \
		--no-interaction

	echo "Install and activate plugins..."
	php ${APP_PATH}/${APP_NAME}/bin/console glpi:plugin:install --username=glpi fusioninventory
	php ${APP_PATH}/${APP_NAME}/bin/console glpi:plugin:activate fusioninventory

	echo "Set correct permissions for app config files..."
	chmod 644 ${APP_PATH}/config/*.php
	chown -R www-data: ${APP_PATH}/config/

	echo "Delete useless directories..."
	rm -fr /tmp/${APP_NAME}/
	rm -f /tmp/*.tpl.php
	rm -rf ${APP_PATH}/${APP_NAME}/install
elif [[ ! -d ${APP_PATH}/${APP_NAME}/install/ ]] && [[ ! -f ${APP_PATH}/${APP_NAME}/version/${APP_VERSION} ]]; then
	echo "Updating ${APP_NAME} to v${APP_VERSION}!"
	cd /tmp

	echo "Clean up update backup files older than 6 months..."
	find  /backups/ -type f -mtime +183 -name '*.backup-update.tar.bz2' -execdir rm -- '{}' \;

	echo "Backup ${APP_NAME} files to /backups directory..."
	cd ${APP_PATH}
	tar jcvf /backups/$(date +"%Y-%m-%d")_glpi_data.backup-update.tar.bz2 ./data
	tar jcvf /backups/$(date +"%Y-%m-%d")_glpi_config.backup-update.tar.bz2 ./config
	tar jcvf /backups/$(date +"%Y-%m-%d")_glpi_plugins.backup-update.tar.bz2 ./${APP_NAME}/plugins
	tar jcvf /backups/$(date +"%Y-%m-%d")_glpi_marketplace.backup-update.tar.bz2 ./${APP_NAME}/marketplace

	echo "Copy app target directory (${APP_PATH}/${APP_NAME}/)..."
	rm -fR ${APP_PATH}/${APP_NAME}/

	echo "Copy app files then clean all..."
	cp -af /tmp/${APP_NAME}/* ${APP_PATH}/${APP_NAME}/

	echo "Copy PHP template files, customize them and clean all..."
	cp --force /tmp/downstream.tpl.php ${APP_PATH}/${APP_NAME}/inc/downstream.php
	sed -i "s#\$[{]APP_PATH[}]#${APP_PATH}#g" ${APP_PATH}/${APP_NAME}/inc/downstream.php

	echo "Update database..."
	set +e
	php ${APP_PATH}/${APP_NAME}/bin/console db:check
	set -e
	php ${APP_PATH}/${APP_NAME}/bin/console db:update --no-interaction

	echo "Delete useless directories..."
	rm -fr /tmp/${APP_NAME}/
	rm -f /tmp/*.tpl.php
	rm -rf ${APP_PATH}/${APP_NAME}/files
	rm -rf ${APP_PATH}/${APP_NAME}/install

	echo "Restore only previous files present in ${APP_PATH}/${APP_NAME}/..."
	cd ${APP_PATH}
	tar xvf /backups/$(date +"%Y-%m-%d")_glpi_plugins.backup-update.tar.bz2
	tar xvf /backups/$(date +"%Y-%m-%d")_glpi_marketplace.backup-update.tar.bz2

	echo "Set correct permissions for app files and directories..."
	find ${APP_PATH}/ -type d -exec chmod 755 {} \;
	find ${APP_PATH}/ -type f -exec chmod 644 {} \;
	chown -R www-data: ${APP_PATH}
else
	echo "${APP_NAME} is already installed !"
fi

# Start Cron service
service cron start

exec "$@"
