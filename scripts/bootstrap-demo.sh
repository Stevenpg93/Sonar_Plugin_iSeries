#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "[bootstrap] Levantando servicios (SonarQube + Postgres)..."
./scripts/up.sh

echo "[bootstrap] Construyendo plugin y copiándolo a ./plugins..."
./scripts/build-plugin.sh

echo "[bootstrap] Reiniciando SonarQube para cargar el plugin..."
./scripts/restart-sonarqube.sh

echo "[bootstrap] Compilando demo-project..."
./scripts/build-demo.sh

echo "[bootstrap] Ejecutando scan del demo..."
./scripts/scan-demo.sh

echo "[bootstrap] OK"
