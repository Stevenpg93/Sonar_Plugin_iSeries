#!/usr/bin/env bash
set -euo pipefail

# Ir a la raíz del proyecto
cd "$(dirname "$0")/.."

# 1. Verificar si podman está instalado
if ! command -v podman >/dev/null 2>&1; then
	echo "Error: No se encontró 'podman'. Por favor, instálalo." >&2
	exit 1
fi

echo "Reiniciando el contenedor de SonarQube..."

# 2. Reiniciar solo el contenedor de la aplicación
# Esto mantiene la base de datos (db) encendida y no borra los volúmenes emptyDir
if podman container restart sonarqube-stack-sonarqube >/dev/null 2>&1; then
    echo "✓ Contenedor 'sonarqube' reiniciado correctamente."
else
    echo "❌ Error: El contenedor no parece estar en ejecución." >&2
    echo "Intenta levantarlo primero con tu script de inicio." >&2
    exit 1
fi

echo "Reiniciado. Revisa logs con: ./scripts/logs.sh"

