# Wiki Jardinalp

## Restaurer le site

**ATTENTION** : avant de supprimer les volumes Docker de Jardinalp assurez vous d'en avoir sauvegarder le contenu !
Si vous êtes sûr de ce que vous faite et que les volumes *nommés* de jardinalp existent, il faut les supprimer :
   - La suppression du volume `root-jardinalp-wiki-storage` permet de tout réinitialiser avec les
   fichiers présents dans l'image `wiki-jardinalp-php`.
   - La suppression du volume `db-jardinalp-wiki-storage` permet de tout réinitialiser avec les
   fichiers (SQL) présents dans le dossier `./mariadb/initdb/`.


### Restaurer les fichiers systèmes

 - Récupérer des backups des fichiers systèmes depuis le dossier `./backups/` avec :
   ```bash
   cp ./backups/<date>_backup_files_jardinalp_* ./yeswiki/build/
   ```
 - Dans le fichier `.env` indiquer la date des fichiers de backup dans le paramètre `YW_BACKUP_DATE`
 - Lancer le rebuild de l'image Docker qui inclura les fichiers précédents :
   ```bash
   docker compose up -d --build wiki-jardinalp-php
   ```

### Restaurer la base de données
Tous les fichiers présents dans `./mariadb/initdb/` seront exécutés et serviront
à restaurer la base lorsque le volume nommé de la base sera créé.

 - Supprimer les anciens dump de base de données pour éviter qu'ils soient restaurés :
   ```bash
   rm -f ./mariadb/initdb/*.sql
   ```
 - Récupérer le dump de la base de données depuis le dossier `./backups/` avec :
   ```bash
   cp ./backups/<date>_wiki-jardinalp.dump.sql ./mariadb/initdb/
   ```
 - **ATTENTION** : Pour que le fichier SQL de sauvegarde soit exécuté lors du lancement du service
 `wiki-jardinalp-mariadb`, il faut au préalable supprimer le volume nommé `db-jardinalp-wiki-storage`.
 Assurez vous d'avoir un fichier de sauvegarde SQL fonctionnel au préalable !


## Sauvegarde wiki-jardinalp

Script Bash de sauvegarde de l'instance `wiki-jardinalp`  
Fonctionne depuis l’hôte, sans modification des conteneurs existants.

Le script effectue :
- un dump SQL complet de la base MariaDB via un conteneur éphémère `mariadb:11.1.2-jammy`
- une copie complète du volume `/var/www/html` du conteneur `wiki-jardinalp-php` (contenu applicatif YesWiki)
- une copie complète des dossiers locaux suivants :
  - `./yeswiki` (contenu du build Docker, thèmes, scripts…)
  - `./nginx` (configuration Nginx spécifique au wiki)
  - `./mariadb` (scripts d’initialisation de la base)
- deux archives gzip distinctes :
  - `wiki-jardinalp.html.tar.gz` (contenu du wiki depuis le conteneur)
  - `wiki-jardinalp.localdirs.tar.gz` (dossiers locaux)
- une rotation automatique des sauvegardes (suppression des sauvegardes trop anciennes)

Aucune donnée externe ni volume non explicitement monté n’est inclus.  
Le script se contente de capturer l’état actuel du wiki et de son environnement local tel que configuré dans le dossier `wiki-jardinalp`.

### Structure de sortie

Un dossier : `YYYY-MM-DD_wiki-jardinalp`

Contenu :
- `wiki-jardinalp.dump.sql.gz` (dump de la base MariaDB)
- `wiki-jardinalp.html.tar.gz` (volume applicatif du wiki)
- `wiki-jardinalp.localdirs.tar.gz` (dossiers locaux yeswiki, mariadb, nginx)
