#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
EDITOR_DIR="$ROOT/kitodo-workflow-editor"
PROD_DIR="$ROOT/kitodo-production"
RESOURCES="$PROD_DIR/Kitodo/src/main/webapp/WEB-INF/resources"

echo "==> Building workflow editor..."
cd "$EDITOR_DIR"
npm install
npm run build

echo "==> Copying dist assets into Kitodo.Production..."
cp "$EDITOR_DIR/dist/js/modeler_min.js"    "$RESOURCES/js/modeler_min.js"
cp "$EDITOR_DIR/dist/js/modeler_custom.js" "$RESOURCES/js/modeler_custom.js"
cp "$EDITOR_DIR/dist/css/modeler.css"      "$RESOURCES/css/modeler.css"
mkdir -p "$RESOURCES/font"
cp "$EDITOR_DIR/dist/font/"*               "$RESOURCES/font/"

echo "==> Integration complete."
echo ""

# Build Maven WAR if needed
echo "==> Building Kitodo.Production Maven artifacts..."
cd "$PROD_DIR"
mvn clean install -P'!development' -DskipTests -B
mkdir -p "$ROOT/build-resources"
cp Kitodo/target/kitodo-*.war "$ROOT/build-resources/kitodo.war"
cat Kitodo/setup/schema.sql Kitodo/setup/default.sql > "$ROOT/build-resources/kitodo.sql"
cp -r Kitodo/modules "$ROOT/build-resources/"

# Build Docker image with updated assets
if command -v docker &>/dev/null; then
  echo "==> Building Kitodo.Production Docker image..."
  cd "$ROOT"
  docker compose -f docker/docker-compose.yml up --build -d
  echo "==> Kitodo.Production available at http://localhost:8080/kitodo"
  echo "    Test accounts (password: test):"
  echo "      - testAdmin (Administration)"
  echo "      - testScanning (Scanning)"
  echo "      - testQC (Quality Control)"
  echo "      - testImaging (Imaging)"
  echo "      - testMetaData (Metadata)"
  echo "      - testProjectmanagement (Project Management)"
else
  echo "    Docker not available. Artifacts built; run manually:"
  echo "    docker compose -f docker/docker-compose.yml up --build -d"
fi
echo ""
echo "Branch status:"
cd "$PROD_DIR" && git branch -v
