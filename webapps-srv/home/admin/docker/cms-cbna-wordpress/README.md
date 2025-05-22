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

## Sauvegarde cms-cbna-wordpress

Script Bash de sauvegarde de l'instance `cms-cbna-wordpress`  
Fonctionne depuis l’hôte, sans modification des conteneurs existants.

Le script effectue :
- un dump SQL compressé via `mariadb-dump`, exécuté depuis un conteneur éphémère (`mariadb:11.1-jammy`)
- une archive gzip des fichiers applicatifs WordPress (`/var/www/html`)
- une rotation automatique des sauvegardes (suppression des sauvegardes trop anciennes)

Le conteneur utilisé pour le dump est temporaire et supprimé automatiquement à la fin (`--rm`).  
Les identifiants de la base sont extraits dynamiquement depuis les variables d’environnement du conteneur MariaDB.  
Les noms des conteneurs cibles sont définis en haut du script.

### Structure de sortie

Un dossier : `YYYY-MM-DD_nom-logique`

Contenu :
- `nom-logique.dump.sql.gz`
- `nom-logique.html.tar.gz`

### Prérequis

- Docker installé sur l’hôte  
- Accès à un conteneur MariaDB exposant les variables `MARIADB_USER` et `MARIADB_PASSWORD`  
- Accès réseau entre l’hôte du dump et le conteneur base de données (`--network container:<nom_du_conteneur>`)  
- Droits suffisants pour exécuter `docker exec`, `docker cp` et `docker run --rm`

