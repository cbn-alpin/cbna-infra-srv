#!/usr/bin/env bash
# Encoding : UTF-8
# Script to backup postgresql database

find  /backups/ -type f -name '*.dump' -execdir rm -- '{}' \;
pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > /backups/$(date +"%Y-%m-%d")_${POSTGRES_DB}.dump.sql

