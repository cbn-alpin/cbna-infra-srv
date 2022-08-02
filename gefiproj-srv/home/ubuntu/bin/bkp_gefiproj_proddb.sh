#!/bin/bash

ADMINDB_CONTAINER=$(docker ps --format "{{.Names}}"|grep 'srv-captain--admin-db')

/usr/bin/docker exec -e PGADMIN_DEFAULT_PASSWORD="<pgadmin-default-password>" ${ADMINDB_CONTAINER} \
	/bin/sh -c 'PGPASSWORD="<pg-password>" /usr/local/pgsql-12/pg_dump --host "srv-captain--proddb-db" --port "5432" --username "dbprod" --verbose --role "dbprod" --jobs "2" --format=d --schema "public" "dbprod" --file /bkp/$(date +"%Y-%m-%d")_backup_dbprod'

/usr/bin/docker exec -e PGADMIN_DEFAULT_PASSWORD="<pgadmin-default-password>" ${ADMINDB_CONTAINER} \
	/bin/sh -c 'PGPASSWORD="<pg-password>" /usr/local/pgsql-12/pg_dump --host "srv-captain--proddb-db" --port "5432" --username "dbprod" --verbose --role "dbprod" --format=plain --schema "public" "dbprod" --file /bkp/$(date +"%Y-%m-%d")_backup_dbprod.sql'

cd /home/ubuntu/backups/postgresql/

sudo chown -R ubuntu: $(date +"%Y-%m-%d")_backup_dbprod*

tar czvf "$(date +"%Y-%m-%d")_backup_dbprod.tar.gz" "./$(date +"%Y-%m-%d")_backup_dbprod" "./$(date +"%Y-%m-%d")_backup_dbprod.sql"

rm -fr "./$(date +"%Y-%m-%d")_backup_dbprod" "./$(date +"%Y-%m-%d")_backup_dbprod.sql"

find ./ -type f -mtime +30 -delete -name "*.sql" -or -name "*.tar.gz"

ls -al ./ | mail -s "[Cron] PgBackup - Gefiproj" -r "mailer@cbn-alpin.fr" adminsys@cbn-alpin.fr
