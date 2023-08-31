#!/usr/bin/env bash
# Encoding : UTF-8
# Script to backup Wiki Jardinalp database and system files

type="${1:-files}"

if [[ "${type}" = "files" ]]; then
	# Usage: docker compose exec wiki-jardinalp-php /backups/backup.sh 'files'
	tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-jardinalp_files.backup.tar.bz2 \
		/var/www/html/files

	tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-jardinalp_map.backup.tar.bz2 \
		/var/www/html/map

	tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-jardinalp_media.backup.tar.bz2 \
		/var/www/html/media

	tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-jardinalp_photos.backup.tar.bz2 \
		/var/www/html/map

	find  /backups/ -type f -mtime +1 -name '*.backup.tar.bz2' -execdir rm -- '{}' \;
elif [[ "${type}" = "database" ]]; then
	# Usage: source .env && docker compose exec wiki-jardinalp-mariadb /backups/backup.sh 'database'
	mariadb-dump -uroot -p${MARIADB_ROOT_PASSWORD} --all-databases > /backups/$(date +"%Y-%m-%d")_wiki-jardinalp.dump.sql

	find  /backups/ -type f -mtime +1 -name '*.dump.sql' -execdir rm -- '{}' \;
else
	echo 1>&2 "Argument must be: 'database' or 'files'";
	exit 1;
fi
