#!/usr/bin/env bash
# Encoding : UTF-8
# Script to backup Gefiproj database

pg_dump -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" > /backups/$(date +"%Y-%m-%d")_gefiproj_${POSTGRES_DB}.dump
find  /backups/ -type f -mtime +4 -name '*.dump' -execdir rm -- '{}' \;
