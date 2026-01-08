#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[reset] Bajando Pod y eliminando contenedores..."

# 1. Eliminar el Pod y sus contenedores de forma forzada
# Al usar kube play, el pod se llama como definiste en el metadata: sonarqube-stack
if podman pod exists sonarqube-stack; then
    podman pod rm -f sonarqube-stack
    echo "✓ Pod 'sonarqube-stack' y sus contenedores eliminados."
else
    echo "ℹ El pod 'sonarqube-stack' no existe o ya fue eliminado."
fi

echo "[reset] Limpiando estado local sensible y artefactos..."

# 2. Borrar archivos temporales y de estado (Igual que en tu script original)
rm -f "$PWD/.sonarqube/sonar.token" || true
rm -f "$PWD/.sonarqube/admin.password" || true
rm -rf "$PWD/demo-project/.scannerwork" || true

# Como usas emptyDir en el YAML, los volúmenes mueren automáticamente 
# con el Pod. No es necesario borrar carpetas de volumen en el host 
# a menos que las hayas mapeado manualmente.

# Opcional: Limpiar los JARs compilados localmente
# rm -rf "$PWD/plugins"/*.jar || true

echo "[reset] Listo. Arranca de nuevo con su script de inicio."
