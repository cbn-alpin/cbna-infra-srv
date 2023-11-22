# Maintenance

## Maintenance

Pour basculer le site UsersHub du CBN Alpin en maintenance,
renommer le fichier `maintenance.disable` en `maintenance.enable`.
```
mv ~/www/maintenance/usershub/maintenance.disable ~/www/maintenance/usershub/maintenance.enable
```

Ce fichier doit simplement exister et avoir le bon nom. Il peut être vide.

## Forcer l'accès au site

Vous pouvez souhaiter accéder au site pour visualiser le résultat de votre travail
de maintenance.

### Via IP
Certaines IP fixes comme celle du serveur ou celles des postes des administrateurs
peuvent être ajouté dans `/etc/nginx/sites-available/usershub.conf`
afin de ne pas afficher la page maintenance.

Les navigateurs présentant ces IP continueront d'accéder normalement au site.

### Via Cookie
Il est aussi possible de court-circuiter la page de maintenance en ajoutant un
cookie nommé `maintenance_disable` au domaine du UsersHub du CBN Alpin.

Vous pouvez passer par le "*DevTools*" de votre navigateur.

Ce cookie doit contenir un UUID spécifique. Si l'UUID coincide avec celui
indiqué dans le fichier `/etc/nginx/sites-available/usershub.conf` la
maintenance est désactivée.
