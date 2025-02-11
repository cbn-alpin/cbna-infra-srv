# PGAdmin

## Port des bases sur l'hôte
Pour rechercher les ports des bases de données accessibles sur l'hôte utiliser la commande :

    ```
    netstat -anpt | grep 432
    ```
Pour chaque stack, vous pouvez également retrouver les informations dans les fichier `.env`.


## Ajout d'un nouveau serveur

Pour chaque stack docker contenant une base de données Postgresql, dans PgAdmin4 :
- Cliquer droit sur : Servers > Nouveau > Serveur...
  - Onglet General :
    - Nom : indiquer le nom de l'outil utilisant la base Postgresql
  - Onglet Connexion :
    - Nom d'hôte / Adresse : localhost
    - Port : port ouvert sur l'hôte du Postgresl du container Docker
    - Base de données de maintenance : nom de la base utilisé par l'outil
    - Nom utilisateur : nom de l'utilisateur Postgresql de l'outil
  - Onglet Tunnel SSH :
    - Cocher "Utiliser un tunnel SSH"
    - Hôte du tunnel : IP v4 du serveur hôte
    - Port du tunnel : port SSH de l'hôte
    - Nom utilisateur : nom de l'utilisateur de l'hôte permettant d'accèder aux base de données via SSH
    - Authentification : Mot de passe
    - Mot de passe : indiqué le mot de passe de l'utilisateur de l'hôte permetant l'accès aux bases
    - Enregistrer le mot de passe ? : activer

## Sauvegarde de la config des serveurs
Via l'interface de PgAdmin4 :
- Outils > Import/Export des serveurs
  - Choisir "Export"
  - Nom de fichier : servers.json
  - Cocher tous les serveurs
  - Cliquer sur "Terminer"
- Sur l'hôte assurer vous que le dossier `~/docker/pgadmin/backups/` possède **temporairement** tous les droits `chmod 777 ~/docker/pgadmin/backups/`
- Se connecter au container Docker : ``
  - Se rendre dans le dossier : `cd /var/lib/pgadmin/storage/<utilisateur>/`
  - Copier le fichier *servers.json* dans le dossier `/bkp/` : `cp ./servers.json /bkp/`
- Sur l'hôte :
  - Copier le fichier servers.json dans le dossier de la stack : `cp backups/servers.json ../servers.json`
  - Le fichier docker-compose.yml se charge ensuite de copier se fichier à l'emplacement `/pgadmin4/servers.json`.

## Importer la config des serveurs
Via l'interface de PgAdmin4 :
- Outils > Import/Export des serveurs
  - Choisir" Import" et suivre l'assistant

Le fichier *servers.json* précédement sauvegarddé devrait se trouver à la racine du dossier accessible via l'explorateur de fichier de PgAdmin4.
