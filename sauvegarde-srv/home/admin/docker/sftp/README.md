# SFTP

## Clés SSH

Générer les clés SSH qui seront utilisées par le serveur SFTP sur l'hôte afin d'éviter que les
utilisateurs recoivent un avertissement MITM après chaque redémarrage du container. Lancer les
commandes suivantes en acceptant toutes les valeurs par défaut des différentes questions :
	```bash
	ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
	ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
	```

## Fichier .env

Indiquer dans le paramètre `HOST_SSH_PORT` le port SSH utilisé pour le SFTP. Il doit être différent
de celui de l'hôte.

## Fichier users.conf

Créer un fichier *users.conf* à partir du fichier *users.sample.conf* : `cp users.sample.conf users.conf`
Par défaut, nous avons 2 utilisateurs seulement dans le fichier *users.conf* :
  - *data* connecté à l'utilisateur de l'hôte *provider* via ses UID et GID. Il peut lire et écrire.
  - *data-reader* qui a accès au même dossier que l'utilisateur *data* mais en lecture seulement.

Pour encrypter les mots de passe, utiliser la commande :
	```bash
	echo -n "mon-mot-de-passe" | docker run -i --rm atmoz/makepasswd --crypt-md5 --clearfrom=-
	```

Pour obtenir les UID et GID de l'utilisateur de l'hôte *provider* utilisé la commande : `id provider`

## Problème d'écriture à la racine d'un dépôt SFTP

L'utilisateur *data* ne peut pas écrire à la racine de son dépôt.
Il faut donc créer en amont les dossiers racines :
- Sur l'hôte, passer en root : `sudo -i`
- Aller dans le dossier de l'utilisateur sur l'hôte : `cd /home/provider/data/`
- Créer les dossiers qui hébergeront les données à intégrer : `mkdir test`
- Donner les droits à l'utilisateur correspondant sur l'hôte (*provider* dans notre cas) d'y accéder en lecture et écriture : `chown provider:users ./*`

## Tester la connexion SFTP

Configurer votre client SFTP :
- Protocole : SFTP
- Hôte : IP du serveur "sauvegarde-srv"
- Port : indiquer la valeur du paramètre HOST_SSH_PORT du fichier .env du container Docker SFTP configuré via l'utilisateur admin.
- Type d'authentification : Normale
- Identifiant : indiquer le nom d'un utilisateur présent dans le fichier *users.conf*.
- Mot de passe : indiquer le mot de passe non crypté de l'utilisateur.
- Enregistrer

Tenter de vous connecter et d'uploader un fichier dans un des dossiers préalablement créé.

Normalement, il est impossible d'uploader des fichiers ou de créer de nouveaux dossiers à la racine.

