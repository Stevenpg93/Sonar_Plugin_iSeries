#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

token="${1:-${SONAR_TOKEN:-}}"

if [[ -z "$token" && -f "$PWD/.sonarqube/sonar.token" ]]; then
  token="$(tr -d '\n' < "$PWD/.sonarqube/sonar.token")"
fi

if [[ -z "$token" ]]; then
  echo "Uso: ./scripts/scan-demo.sh [SONAR_TOKEN]" >&2
  echo "- O exporta SONAR_TOKEN" >&2
  echo "- O guarda un token en .sonarqube/sonar.token" >&2
  exit 2
fi

network="sonarqube_default"

scanner_image="${SCANNER_IMAGE:-sonarsource/sonar-scanner-cli:latest}"

# SonarScanner en contenedor, apuntando al servicio 'sonarqube' en la red del compose.
docker run --rm \
  --network "$network" \
  -v "$PWD/demo-project:/usr/src" \
  "$scanner_image" \
  -Dsonar.projectBaseDir=/usr/src \
  -Dsonar.host.url=http://sonarqube:9000 \
  -Dsonar.token="$token"
