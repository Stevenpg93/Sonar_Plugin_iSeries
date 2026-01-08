#!/usr/bin/env bash
set -euo pipefail

# 1. Posicionarse en la raíz del proyecto
cd "$(dirname "$0")/.."

# 2. Gestión del Token
token="${1:-${SONAR_TOKEN:-}}"
if [[ -z "$token" && -f "$PWD/.sonarqube/sonar.token" ]]; then
  token="$(tr -d '\n' < "$PWD/.sonarqube/sonar.token")"
fi

if [[ -z "$token" ]]; then
  echo "Error: Se requiere un token de SonarQube." >&2
  exit 2
fi

# 3. Configuración
pod_name="sonarqube-stack"
scanner_image="${SCANNER_IMAGE:-sonarsource/sonar-scanner-cli:latest}"

echo "Iniciando análisis con Podman en el pod $pod_name..."

# 1. Definimos un nombre temporal para el contenedor para poder manipularlo
container_name="sonar-scanner-temp-$(date +%s)"

# 2. Ejecutamos SIN el flag --rm para que no choque con el recolector de basura de Podman
MSYS_NO_PATHCONV=1 podman run \
  --name "$container_name" \
  --pod "$pod_name" \
  -v "$PWD/demo-project:/usr/src:Z" \
  "$scanner_image" \
  -Dsonar.projectBaseDir=/usr/src \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token="$token"

# 3. Borramos el contenedor manualmente de forma forzada después de la ejecución
echo "Limpiando contenedor de análisis..."
podman rm -f "$container_name" >/dev/null 2>&1

echo "Análisis completado."
