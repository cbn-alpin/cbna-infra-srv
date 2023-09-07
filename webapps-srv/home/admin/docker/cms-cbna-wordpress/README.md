# Docker wordpress

Docker Compose de l'API wordpress ainsi que les mécanismes permettant de le gérer :
    - Wordpress v6.0.0
    - Wordpress-cli
    - Mariadb - sql
    - Nginx
    - Backup systéme

## Restauration du dossier wp-content

1. Supprimer le dossier `wp-content/` dans le volume wordpress avec : `docker exec -it cms-cbna-wordpress rm -rf /var/www/html/wp-content`
1. Copier le contenant du dossier local `wp-content` après l'avoir décompressé : `docker cp <local-backup-path> cms-cbna-wordpress:/var/www/html/`


## Restauration de la base de données

1. Si la sauvegarde de la base a été créé avec l'option `--add-drop-table` :
	```bash
		cat <dump.sql> | docker exec -i cms-cbna-backup-cron mysql -P 3306 -h 172.18.5.2 -u <user> -p<password> -B <database>
	```
1. Pour vérifeir l'IP utilisée par le container de MariaDB, vous pouvez utiliser la commande : `docker network inspect nginx-proxy`

## Copie manuelle du dossier wp-content

Du container vers un dossier local : `docker cp cms-cbna-wordpress:/var/www/html/wp-content <local-directory-path>`

## Création manuelle d'une sauvegarde la base de données

1. Entrer dans le container réalisant les sauvegardes de la base : `docker exec -it cms-cbna-backup-cron /bin/bash`
1. Lancer la commande de sauvegarde : `mysqldump -P 3306 -h 172.18.5.2 -u <user> -p<password> -B <database> > /var/www/html/backup/<namedump.sql>`
1. Sortir du container : `exit`
