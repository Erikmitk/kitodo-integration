#!/usr/bin/env bash
set -euo pipefail

WEBAPPS=/usr/local/tomcat/webapps
APP_DIR="${WEBAPPS}/kitodo"
WAR=/tmp/kitodo/kitodo.war

# Remove old deploy if present
rm -rf "${APP_DIR}"

# Unpack WAR
mkdir -p "${APP_DIR}"
unzip -q "${WAR}" -d "${APP_DIR}"

HIBERNATE="${APP_DIR}/WEB-INF/classes/hibernate.cfg.xml"
KITODO_CFG="${APP_DIR}/WEB-INF/classes/kitodo_config.properties"

# Patch hibernate.cfg.xml — JDBC host:port + credentials
sed -i "s|jdbc:mysql://[^/]*/|jdbc:mysql://${DB_HOST}:${DB_PORT}/|g" "${HIBERNATE}"
sed -i "s|kitodo?useSSL=false|${DB_NAME}?useSSL=false\&amp;allowPublicKeyRetrieval=true\&amp;serverTimezone=UTC|g" "${HIBERNATE}"
sed -i "s|connection.username\">kitodo|connection.username\">${DB_USER}|g" "${HIBERNATE}"
sed -i "s|connection.password\">kitodo|connection.password\">${DB_PASSWORD}|g" "${HIBERNATE}"

# Patch hibernate — set hbm2ddl to update (auto-create missing tables)
sed -i "s|<property name=\"hbm2ddl.auto\">validate</property>|<property name=\"hbm2ddl.auto\">update</property>|g" "${HIBERNATE}"

# Patch hibernate.cfg.xml — Elasticsearch backend hosts
sed -i "s|localhost:9200|${ES_HOST}:${ES_PORT}|g" "${HIBERNATE}"

# Patch kitodo_config.properties — modules directory (outside the volume mount)
sed -i "s|^\(directory\.modules\)=.*|\1=/opt/kitodo/modules/|" "${KITODO_CFG}" 2>/dev/null || true

# Patch kitodo_config.properties — OpenSearch host
sed -i "s|^\(elasticsearch\.host\)=.*|\1=${ES_HOST}|" "${KITODO_CFG}" 2>/dev/null || true
sed -i "s|^\(elasticsearch\.port\)=.*|\1=${ES_PORT}|" "${KITODO_CFG}" 2>/dev/null || true

echo "==> Deployed and patched kitodo at ${APP_DIR}"
