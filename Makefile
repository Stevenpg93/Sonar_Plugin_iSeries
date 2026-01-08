.PHONY: help bootstrap up down logs restart plugin demo init scan reset

help:
	@echo "Targets disponibles:"
	@echo "  make bootstrap   # End-to-end: up + build plugin + restart + build demo + init + scan"
	@echo "  make up          # Levanta SonarQube + Postgres (docker-compose)"
	@echo "  make down        # Baja el stack (docker-compose)"
	@echo "  make logs        # Logs de SonarQube (follow)"
	@echo "  make restart     # Reinicia SonarQube (carga plugin desde ./plugins)"
	@echo "  make plugin      # Build plugin + copia a ./plugins"
	@echo "  make demo        # Compila demo-project"
	@echo "  make scan        # Ejecuta SonarScanner (usa SONAR_TOKEN o .sonarqube/sonar.token)"

bootstrap:
	./scripts/bootstrap-demo.sh

up:
	./scripts/up.sh

down:
	./scripts/down.sh

logs:
	./scripts/logs.sh

restart:
	./scripts/restart-sonarqube.sh

plugin:
	./scripts/build-plugin.sh

demo:
	./scripts/build-demo.sh

scan:
	./scripts/scan-demo.sh

reset:
	./scripts/reset-sonarqube.sh
