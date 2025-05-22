# gefiproj

## Sauvegarde gefiproj

Script Bash de sauvegarde de l'instance `gefiproj`  
Fonctionne depuis l’hôte, sans modification des conteneurs existants.

Le script effectue :
- un dump SQL compressé via `pg_dump`, exécuté depuis un conteneur éphémère (`postgres:15.3-bookworm`)
- une archive gzip des fichiers de configuration extraits de l’API (`/home/app/web/config`, `/var/logs`)
- une copie optionnelle des hooks Webhook (`/etc/webhook/hooks.json`, `/var/scripts`)
- une rotation automatique des sauvegardes (suppression des sauvegardes trop anciennes)

Le conteneur utilisé pour le dump est temporaire et supprimé automatiquement à la fin (`--rm`).  
Les identifiants de la base sont extraits dynamiquement depuis les variables d’environnement du conteneur PostgreSQL.  
Les noms des conteneurs cibles sont définis en haut du script.

### Structure de sortie

Un dossier : `YYYY-MM-DD_gefiproj`

Contenu :
- `gefiproj.dump.sql.gz`
- `gefiproj.configs.tar.gz`

### Prérequis

- Docker installé sur l’hôte  
- Accès à un conteneur PostgreSQL exposant les variables `POSTGRES_USER`, `POSTGRES_PASSWORD` et `POSTGRES_DB`  
- Accès réseau entre l’hôte du dump et le conteneur base de données (`--network container:<nom_du_conteneur>`)  
- Droits suffisants pour exécuter `docker exec`, `docker cp` et `docker run --rm`
