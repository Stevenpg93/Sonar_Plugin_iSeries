#!/usr/bin/env bash
set -euo pipefail

# 1. Posicionarse en la raíz del proyecto
cd "$(dirname "$0")/.."

echo "Construyendo plugin con Maven..."
# Compilar el proyecto
(cd plugin-todo-check && mvn clean package -DskipTests)

# 2. Identificar el archivo JAR generado
jar_file=$(ls -1 plugin-todo-check/target/sonar-todo-check-plugin-*.jar | head -n 1)
jar_name=$(basename "$jar_file")

# 3. Crear copia local por respaldo (opcional, según tu script original)
mkdir -p plugins
cp "$jar_file" plugins/
echo "✓ Plugin copiado localmente a ./plugins/$jar_name"

# 4. COPRA ADICIONAL: Inyectar en el volumen de Podman
# Verificamos si el contenedor está corriendo antes de copiar
if podman ps --format "{{.Names}}" | grep -q "sonarqube-stack-sonarqube"; then
    echo "Copiando plugin al volumen de extensiones en el contenedor..."
    
    # Copia el JAR directamente a la carpeta de plugins dentro del volumen montado
    podman cp "$jar_file" sonarqube-stack-sonarqube:/opt/sonarqube/extensions/plugins/
    
    echo "✓ Plugin inyectado en /opt/sonarqube/extensions/plugins/"
    echo "Siguiente paso: Ejecutar ./scripts/restart-sonarqube.sh para aplicar cambios"
else
    echo "⚠️  El contenedor 'sonarqube-stack-sonarqube' no está activo."
    echo "Inicia primero el entorno con tu script de arranque para poder copiar el plugin al volumen."
fi
