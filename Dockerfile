# syntax=docker/dockerfile:1

# ============================================================
#  Frontend (Innovatech) - EP3 DevOps
#  Imagen multi-stage:
#   1) build  -> compila los estaticos con Maven (Java 17)
#   2) runtime-> los sirve con nginx en el puerto 80
#
#  Las URLs de los backends se inyectan en TIEMPO DE EJECUCION
#  (no en build), usando variables de entorno de la Task
#  Definition. En build se dejan placeholders que el entrypoint
#  reemplaza al arrancar el contenedor.
# ============================================================

# ---- Stage 1: build de los estaticos ----
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app

# Cache de dependencias: primero el pom
COPY pom.xml ./
RUN mvn -B dependency:resolve || true

# Codigo fuente
COPY src ./src

# .env con PLACEHOLDERS que el entrypoint sustituira en runtime.
# El generador Java reemplaza {{BACKEND_*}} por estos valores,
# dejando los tokens __BACKEND_*__ dentro de script.js
RUN printf 'BACKEND_USERS_URL=__BACKEND_USERS_URL__\nBACKEND_PRODUCTS_URL=__BACKEND_PRODUCTS_URL__\n' > .env

# Genera output/index.html, styles.css, script.js
RUN mvn -B clean compile exec:java

# ---- Stage 2: runtime con nginx ----
FROM nginx:1.27-alpine

# Estaticos generados
COPY --from=build /app/output /usr/share/nginx/html

# Config de nginx (healthcheck + fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Script que inyecta las URLs reales al arrancar.
# nginx ejecuta automaticamente los *.sh de /docker-entrypoint.d/
COPY docker-entrypoint.sh /docker-entrypoint.d/40-inject-backend-urls.sh
RUN chmod +x /docker-entrypoint.d/40-inject-backend-urls.sh

EXPOSE 80
