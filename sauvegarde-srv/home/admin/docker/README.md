# Docker

## Synchronisation serveur
### Synchroniser un dossier Docker

Pour transférer uniquement un dossier contenant les fichiers Docker d'un domaine
sur le serveur, utiliser `rsync` en testant avec l'option `--dry-run` (à supprimer quand tout est ok):

```shell
# Exemple pour analytics
cd analytics
rsync -av --copy-unsafe-links ./ admin@sauvegarde:~/docker/analytics/ --dry-run
```

### Synchroniser l'ensemble des dossiers Docker

Pour synchroniser ces fichiers avec le serveur utiliser `rsync` :
 - Se placer à la racine du dépôt
 - Lancer la commande `rsync` suivante, ici pour *sauvegarde-srv* et le dossier *docker* avec l'option `--dry-run` (à supprimer quand tout est ok):

```shell
rsync -av ./sauvegarde-srv/home/admin/docker/ admin@sauvegarde:/home/admin/docker/ --dry-run
```

## Commandes utiles avec les images Docker

### InfluxDb
#### Récupérer le fichier de configuration par défaut

```shell
docker run --rm influxdb:1.8.4 influxd config > sauvegarde-srv/home/admin/docker/monitor/influxdb/influxdb.default.conf
```

### Telegraf
#### Récupérer le fichier de configuration par défaut

```shell
docker run --rm telegraf:1.18.1 telegraf config | \
  tee sauvegarde-srv/home/admin/docker/monitor/telegraf/telegraf.sample.conf > /dev/null
```

### Portainer
#### Brcypter le mot de passe admin

```shell
 htpasswd -bnBC 10 "" <mot-de-passe-admin> | tr -d ':\n'
```

