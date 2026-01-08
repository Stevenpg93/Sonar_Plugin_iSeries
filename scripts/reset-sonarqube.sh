#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[reset] Bajando stack y borrando volúmenes (DB + data SonarQube)..."
# -v: elimina volúmenes nombrados (postgres_data, sonarqube_data, sonarqube_extensions)
docker-compose down -v

echo "[reset] Limpiando estado local sensible (tokens/passwords) y artefactos..."
rm -f "$PWD/.sonarqube/sonar.token" || true
rm -f "$PWD/.sonarqube/admin.password" || true
rm -rf "$PWD/demo-project/.scannerwork" || true

# Opcional: si quieres un reset TOTAL de plugins copiados, descomenta.
# rm -f "$PWD/plugins"/*.jar || true

echo "[reset] Listo. Arranca de nuevo con: ./scripts/up.sh"
