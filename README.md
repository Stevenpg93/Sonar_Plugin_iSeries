# Guía práctica — Desarrollar un plugin para SonarQube Community (local con Docker)

Objetivo: tener en **un solo workspace**:
- SonarQube Community corriendo en local con Docker.
- Un **plugin sencillo** (Java) que detecta líneas con `TODO` y crea issues.
- Un **proyecto demo** para escanear y validar el plugin.

Estructura (ya creada en este workspace):

- `docker-compose.yml` → SonarQube + PostgreSQL
- `plugins/` → carpeta mapeada al contenedor (`/opt/sonarqube/extensions/plugins`)
- `plugin-todo-check/` → código fuente del plugin
- `demo-project/` → proyecto a escanear
- `scripts/` → comandos para levantar, compilar, instalar y escanear
- `Makefile` → atajos para simplificar workflows

---

## Comandos rápidos (Makefile)

Este workspace incluye un **Makefile** para simplificar operaciones comunes:

| Comando | Descripción |
|---------|-------------|
| `make help` | Muestra todos los comandos disponibles |
| `make bootstrap` | **Todo en uno**: levanta Docker + construye plugin + reinicia + compila demo + configura + escanea |
| `make up` | Levanta SonarQube + PostgreSQL |
| `make down` | Detiene el stack |
| `make logs` | Muestra logs de SonarQube (follow mode) |
| `make plugin` | Construye el plugin y lo copia a `./plugins/` |
| `make restart` | Reinicia SonarQube para cargar plugins |
| `make demo` | Compila el proyecto demo |
| `make scan` | Ejecuta SonarScanner (usa token de `.sonarqube/sonar.token`) |
| `make reset` | Reseteo completo: `docker-compose down -v` + limpieza |

**Tip**: Usa `make help` para ver la lista actualizada de comandos.

---

## Requisitos

- macOS + Docker Desktop
- Java 17 (ya tienes `17.0.15`)
- Maven 3.9+ (ya tienes `3.9.9`)

Notas importantes:
- SonarQube **no soporta hot-reload** de plugins: normalmente debes **reiniciar** SonarQube para cargar un JAR nuevo.

---

## Paso 1 — Levantar SonarQube en local con Docker (con volumen de plugins)

1) Levanta el stack:

```bash
make up
```

Nota (red corporativa): este workspace usa por defecto la convención:

`artifactory.apps.bancolombia.com/<nombre-exacto-de-la-imagen-en-docker-hub>`

Ejemplos:
- `postgres:15-alpine` → `artifactory.apps.bancolombia.com/postgres:15-alpine`
- `sonarqube:community` → `artifactory.apps.bancolombia.com/sonarqube:community`
- `sonarsource/sonar-scanner-cli:latest` → `artifactory.apps.bancolombia.com/sonarsource/sonar-scanner-cli:latest`

En macOS este repo usa `docker-compose` por defecto.

2) Abre SonarQube:

- URL: http://localhost:9000
- Usuario/clave: `admin` / `admin`

3) Espera a que esté "UP". Si tarda:

```bash
make logs
```

**Volumen clave**:
- La carpeta `./plugins` del workspace está mapeada a:
  `/opt/sonarqube/extensions/plugins`

Eso permite instalar el plugin sólo copiando el `.jar` ahí.

---

## Paso 2 — Preparar el plugin de ejemplo (TODO Check)

### Qué hace el plugin
- Define 1 regla para Cobol: **"Evitar comentarios TODO"**.
- Implementa un `Sensor` que recorre archivos `.CBL` y crea un issue por cada línea que contenga `TODO`.

Código:
- `plugin-todo-check/src/main/java/com/example/sonar/todo/TodoCheckPlugin.java`
- `plugin-todo-check/src/main/java/com/example/sonar/todo/TodoRulesDefinition.java`
- `plugin-todo-check/src/main/java/com/example/sonar/todo/TodoSensor.java`

### Compilar el plugin

Este repo incluye un enfoque práctico:

Ejecuta:

```bash
make plugin
```

Esto:
- genera `plugin-todo-check/target/todo-check-plugin-*.jar`
- lo copia a `./plugins/`

Luego reinicia SonarQube para que lo cargue:

```bash
make restart
```

Verificación rápida:
- Revisa logs buscando el nombre del plugin o "todo-check":

```bash
make logs
```

En la UI también puedes ir a:
- **Administration → System → Installed Plugins** (puede variar ligeramente por versión)

---

## Paso 3 — Activar la regla del plugin en un Quality Profile

Por defecto, las reglas nuevas suelen venir **desactivadas**.

1) En SonarQube UI, entra a **Quality Profiles**.
2) Selecciona **Profile**.
3) Edita el profile (o crea uno nuevo) y **activa** la regla del repositorio:
   - Repository: `todo-check`
   - Rule: `todo-comment`

Tip: busca por "TODO Check" o por "Evitar comentarios TODO".

---

## Paso 4 — Escanear el proyecto demo y ver issues

### 4.1 Compilar el demo

```bash
make demo
```

### 4.2 Crear token

En SonarQube UI:
- **My Account → Security → Generate Token**

Guárdalo (no se vuelve a mostrar).

### 4.3 Ejecutar el scan

```bash
make scan
```

**Nota**: El comando `make scan` busca automáticamente el token en `.sonarqube/sonar.token`. También puedes exportar manualmente:

```bash
export SONAR_TOKEN="<tu_token>"
make scan
```

Resultado esperado:
- En el proyecto **demo-project**, verás un issue creado por el plugin en la línea con `TODO`.

---

## Paso 5 — Ciclo de desarrollo (iterar rápido)

Cada vez que cambies el plugin:

```bash
make plugin    # Construye el plugin
make restart   # Reinicia SonarQube
make scan      # Re-escanea el proyecto
```

**Workflow completo en 3 comandos** 🚀

---

## Atajo — Dejar todo listo en un solo comando

Si quieres automatizar todo (levantar Docker, construir plugin, reiniciar SonarQube, compilar demo, crear proyecto, crear un Quality Profile editable, activar la regla y ejecutar el scan), usa:

```bash
make bootstrap
```

Notas:
- Por defecto intenta generar un token con `admin/admin` y lo guarda en `.sonarqube/sonar.token` (no lo imprime).
- Si cambiaste credenciales, exporta un token ya creado antes de ejecutar:

```bash
export SONAR_TOKEN="<tu_token>"
make bootstrap
```

---

## Reseteo completo

Si necesitas empezar desde cero (elimina volúmenes de Docker y estado local):

```bash
make reset
```

**⚠️ Advertencia**: Esto elimina toda la base de datos de SonarQube y configuraciones.

---

## Alternativa sin Makefile

Si prefieres ejecutar scripts directamente, todos los comandos están disponibles en `./scripts/`:

```bash
./scripts/up.sh                    # en lugar de: make up
./scripts/build-plugin.sh          # en lugar de: make plugin
./scripts/restart-sonarqube.sh     # en lugar de: make restart
./scripts/scan-demo.sh             # en lugar de: make scan
```