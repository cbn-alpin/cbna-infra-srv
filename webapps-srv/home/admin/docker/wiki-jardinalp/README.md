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
