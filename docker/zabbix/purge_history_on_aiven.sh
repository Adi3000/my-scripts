. /etc/default/zabbix
echo "Starting container ${0%.sh}"
docker run -it --rm --name "${0%.sh}" --entrypoint psql jbergknoff/postgresql-client  "$AIVEN_POSTGRES_URL" -c "DELETE FROM history WHERE clock < $(date +%s) - 604800 ; DELETE FROM history_uint WHERE clock < $(date +%s) - 604800; COMMIT; VACUUM full history, history_uint;"
docker run -it --rm --name "${0%.sh}" --entrypoint psql jbergknoff/postgresql-client  "$AIVEN_POSTGRES_URL" -c "VACUUM full history, history_uint;"
