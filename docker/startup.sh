#!/usr/bin/env bash
set -euo pipefail

echo "==> Seeding default data files into kitodo data directory..."
cp -rn /opt/kitodo-seed/. /usr/local/kitodo/

echo "==> Waiting for database..."
/wait-for-it.sh -t 120 "${DB_HOST}:${DB_PORT}"

# Check if database has been initialized
INIT_CHECK=$(mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" \
  -e "SHOW TABLES" "${DB_NAME}" 2>/dev/null | wc -l)

if [ "$INIT_CHECK" -lt 5 ]; then
  echo "==> Initialising database with base schema..."
  mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" "${DB_NAME}" < /tmp/kitodo/kitodo.sql 2>&1 | grep -v "ERROR 1050" || true

  echo "==> Running database migrations..."
  /usr/bin/migrate.sh
else
  echo "==> Database already initialised, skipping."
fi

echo "==> Waiting for OpenSearch..."
/wait-for-it.sh -t 120 "${ES_HOST}:${ES_PORT}"

echo "==> Deploying application..."
/usr/bin/deploy.sh

echo "==> Starting Tomcat..."
exec catalina.sh run
