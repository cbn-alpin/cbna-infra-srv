#!/usr/bin/env bash
# Encoding : UTF-8
# Script to backup Dokuwiki system files

tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-intranet_conf_pages.tar.bz2 \
	/var/www/html/conf \
	/var/www/html/data/attic \
	/var/www/html/data/meta \
	/var/www/html/data/pages

tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-intranet_media.tar.bz2 \
	/var/www/html/data/media \
	/var/www/html/data/media_meta \
	/var/www/html/data/media_attic

tar jcvf /backups/$(date +"%Y-%m-%d")_wiki-intranet_plugins_templates.tar.bz2 \
	/var/www/html/lib

find  /backups/ -type f -mtime +3 -name '*.tar.bz2' -execdir rm -- '{}' \;
