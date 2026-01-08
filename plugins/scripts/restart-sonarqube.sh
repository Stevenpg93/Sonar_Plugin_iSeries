#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v docker-compose >/dev/null 2>&1; then
	echo "No se encontró 'docker-compose'. Instálalo/actívalo en Docker Desktop." >&2
	exit 1
fi

docker-compose restart sonarqube

echo "Reiniciado. Revisa logs con: ./scripts/logs.sh"
