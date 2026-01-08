#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# 1. Verificar instalación
if ! command -v podman >/dev/null 2>&1; then
    echo "Error: 'podman' no está instalado." >&2
    exit 1
fi

# 2. Preparar el entorno (ignora errores si ya está listo)
echo "Asegurando que la máquina Podman esté lista..."
podman machine init 2>/dev/null || true
podman machine start 2>/dev/null || true

# 3. Ejecutar el despliegue
echo "Lanzando SonarQube..."
podman kube play --replace sonarqube-pod.yaml

echo "SonarQube: http://localhost:9000 (admin/admin)"
