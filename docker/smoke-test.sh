#!/usr/bin/env bash
set -euo pipefail
BASE="http://localhost:8080/kitodo"
MAX=30; i=0
until curl -sf "$BASE" -o /dev/null; do
  sleep 5; i=$((i+1))
  [ $i -ge $MAX ] && echo "Timeout waiting for app" && exit 1
done
echo "App reachable"

HTTP=$(curl -s -o /dev/null -w "%{http_code}" "$BASE/login.jsf")
[ "$HTTP" = "200" ] && echo "Login page OK" || (echo "Login page returned $HTTP"; exit 1)

curl -sf "http://localhost:9200/kitodo-process-000001" -o /dev/null && echo "OpenSearch index OK"

docker exec "$(docker compose ps -q kitodo-app)" ls /opt/kitodo/modules/ | grep -q "kitodo-command" \
  && echo "Modules OK" || (echo "Modules missing"; exit 1)
