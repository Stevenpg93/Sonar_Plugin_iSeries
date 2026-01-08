#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "Construyendo demo-project ..."

(cd demo-project)

echo "✓ Demo compilado exitosamente"
