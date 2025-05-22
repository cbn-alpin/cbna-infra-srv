#!/bin/bash
# Auteur : Arnaud Ungaro
# Structure : CBNA (Conservatoire Botanique National Alpin)
# Année : 2025
# Script de sauvegarde de l’instance GefiProj

set -e
set -o pipefail

cd "$(dirname "$0")"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

nom_sauvegarde="gefiproj"
repertoire_sauvegarde="/home/admin/docker/gefiproj/backups"
date_du_jour=$(date +%F)
dossier_cible="${repertoire_sauvegarde}/${date_du_jour}_${nom_sauvegarde}"
dossier_temporaire="${dossier_cible}/tmp"
retenue_jours=2

conteneur_bdd="gefiproj-postgres"
conteneur_api="gefiproj-api"
conteneur_webhook="gefiproj-webhook"

image_dump="postgres:15.3-bookworm"

echo "----------------------------------------"
echo "DÉMARRAGE DE LA SAUVEGARDE : ${date_du_jour}"
echo "Nom logique : ${nom_sauvegarde}"
echo "Répertoire de travail : ${dossier_cible}"
echo "Conteneur base de données : ${conteneur_bdd}"
echo "Conteneur API : ${conteneur_api}"
echo "Image utilisée pour le dump : ${image_dump}"
echo "----------------------------------------"
echo ""

if [ -d "${dossier_cible}" ]; then
    echo "Le dossier de destination existe déjà, suppression..."
    rm -rf "${dossier_cible}"
fi

echo "Création du répertoire de sauvegarde..."
mkdir -p "${dossier_temporaire}"
echo ""

echo "Extraction des identifiants depuis le conteneur base de données..."
utilisateur_bdd=$(docker exec "${conteneur_bdd}" printenv POSTGRES_USER)
motdepasse_bdd=$(docker exec "${conteneur_bdd}" printenv POSTGRES_PASSWORD)
nom_base=$(docker exec "${conteneur_bdd}" printenv POSTGRES_DB)

if [[ -z "${utilisateur_bdd}" || -z "${motdepasse_bdd}" || -z "${nom_base}" ]]; then
    echo "Erreur : identifiants ou nom de base incomplets ou introuvables."
    exit 1
fi
echo ""

echo "Export de la base PostgreSQL '${nom_base}' via pg_dump (conteneur éphémère)..."
docker run --rm \
  --network container:"${conteneur_bdd}" \
  -e PGPASSWORD="${motdepasse_bdd}" \
  "${image_dump}" \
  pg_dump -h 127.0.0.1 -U "${utilisateur_bdd}" -d "${nom_base}" -F c \
  | gzip > "${dossier_cible}/${nom_sauvegarde}.dump.sql.gz"
echo "Dump SQL terminé : ${nom_sauvegarde}.dump.sql.gz"
echo ""

echo "Copie des fichiers de configuration de l'API..."
docker cp "${conteneur_api}:/home/app/web/config" "${dossier_temporaire}/config-api" || echo "Répertoire config introuvable"
docker cp "${conteneur_api}:/var/logs" "${dossier_temporaire}/logs-api" || echo "Répertoire logs introuvable"
echo ""

if docker exec "${conteneur_webhook}" test -e /etc/webhook/hooks.json; then
  echo "Copie des hooks Webhook..."
  docker cp "${conteneur_webhook}:/etc/webhook/hooks.json" "${dossier_temporaire}/hooks.json"
  docker cp "${conteneur_webhook}:/var/scripts" "${dossier_temporaire}/scripts" || echo "Répertoire scripts manquant"
  echo ""
fi

echo "Archivage des fichiers de configuration..."
if ! tar czf "${dossier_cible}/${nom_sauvegarde}.configs.tar.gz" -C "${dossier_temporaire}" .; then
    echo "Erreur : archivage échoué."
    exit 1
fi
echo "Archive créée : ${nom_sauvegarde}.configs.tar.gz"
echo ""

echo "Nettoyage du dossier temporaire..."
rm -rf "${dossier_temporaire}"

chmod -R 700 "${dossier_cible}"

echo "Rotation des sauvegardes : conservation de ${retenue_jours} jours..."
date_limite=$(date -d "-${retenue_jours} days" +%Y-%m-%d)
date_limite_ts=$(date -d "${date_limite}" +%s)
echo "Date limite pour conservation : ${date_limite}"
echo ""

set +e

for dossier in "${repertoire_sauvegarde}/"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_"${nom_sauvegarde}"; do
    if [ -d "${dossier}" ]; then
        dossier_base=$(basename "${dossier}")
        dossier_date=$(echo "${dossier_base}" | grep -Eo '^[0-9]{4}-[0-9]{2}-[0-9]{2}')

        if [[ ! "${dossier_date}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
            echo "IGNORÉ (format non conforme) : ${dossier}"
            continue
        fi

        dossier_date_ts=$(date -d "${dossier_date}" +%s)

        if [ "${dossier_date_ts}" -lt "${date_limite_ts}" ]; then
            echo "SUPPRESSION programmée : ${dossier}"
            if rm -rfv "${dossier}"; then
                echo "SUPPRESSION RÉUSSIE : ${dossier}"
            else
                echo "ÉCHEC DE LA SUPPRESSION : ${dossier}"
            fi
        else
            echo "CONSERVÉ : ${dossier}"
        fi
    fi
done

set -e

echo ""
echo "Sauvegarde terminée avec succès."
exit 0
