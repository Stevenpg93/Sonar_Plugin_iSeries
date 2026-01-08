#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Construyendo plugin con Maven..."

(cd plugin-todo-check && mvn clean package -DskipTests)

jar_file=$(ls -1 plugin-todo-check/target/sonar-todo-check-plugin-*.jar | head -n 1)
mkdir -p plugins
cp "$jar_file" plugins/

echo "✓ Plugin copiado a ./plugins/$(basename "$jar_file")"
echo "Siguiente paso: ./scripts/restart-sonarqube.sh"
