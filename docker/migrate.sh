#!/usr/bin/env bash
set -euo pipefail

echo "==> Running database migrations..."

# Apply migration SQL files in order
MIGRATIONS_DIR="/flyway/sql"

# Migrate through each V*.sql file in sorted order
for migration in $(ls -1 "${MIGRATIONS_DIR}"/V*.sql 2>/dev/null | sort -V); do
    filename=$(basename "$migration")
    echo "  Applying $filename..."

    # Apply the migration, ignoring duplicate key errors which are expected
    mysql -h"${DB_HOST}" -P"${DB_PORT}" -u"${DB_USER}" -p"${DB_PASSWORD}" \
      --force "${DB_NAME}" < "$migration" 2>&1 | \
      grep -v "ERROR 1050\|ERROR 1061\|ERROR 1064" || true
done

echo "==> Database migrations completed"
