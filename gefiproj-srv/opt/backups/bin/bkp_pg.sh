#!/bin/bash
# Encoding : UTF-8
# Backup Gefiproj Postgresql Database

db_name="dbprod"
db_user="dbprod"
db_host="localhost"
db_port="55432"

email_from="mailer@cbn-alpin.fr"
email_to="informatique@cbn-alpin.fr"

bkp_dir="/home/ubuntu/backups/postgresql"
bkp_name="$(date +%F)_${db_name}"
bkp_file="${bkp_name}/"
bkp_path="${bkp_dir}/${bkp_file}"
bkp_log="/tmp/pgdump_${db_name}.log"


echo "Start at $(date '+%Y-%m-%d %T')" > ${bkp_log}
# Build and go to backup dir
mkdir -p "${bkp_dir}"
cd "${bkp_dir}"

# Create dump
pg_dump --file "${bkp_path}" \
        --host "${db_host}" \
        --port "${db_port}" \
        --username "${db_user}" \
        --verbose \
        --format=d \
        --jobs=$(grep -c ^processor /proc/cpuinfo) \
        --compress 9 \
        "${db_name}" >> ${bkp_log} 2>&1
# Save exit code of pg_dump process into variable
dump_status=$?

# Create a tar not compressed (already done by dump)
tar -cf "${bkp_name}.tar" -C "${bkp_dir}" "${bkp_file}"

# Clean temp file and old dumps
rm -fR "${bkp_file}"
find "${bkp_dir}" -name "*_${db_name}.tar" -type f -mtime +5 -exec rm -f {} \;

echo "End at $(date '+%Y-%m-%d %T')" >> ${bkp_log}

dump_status=1

# Send email if something goes wrong with dump
if [[ ${dump_status} -ne 0 ]] ; then
        EMAIL="${email_from}"; echo "See attached log file." | mutt \
                -s "[Cron] Backups ERROR ${dump_status} - DB ${db_name} - $(date '+%Y-%m-%d %T')" \
                -a "${bkp_log}" -- \
                "${email_to}"
fi
