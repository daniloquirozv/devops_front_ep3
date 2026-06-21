# syntax=docker/dockerfile:1

# ---- Build stage ----
# Genera la página estática con Maven (mvn clean compile exec:java)
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Cache de dependencias
COPY pom.xml ./
RUN mvn -B dependency:resolve

# Código fuente y configuración usada durante la generación
COPY src ./src
COPY .env* ./

# Genera los archivos estáticos en /app/output
RUN mvn -B clean compile exec:java

# ---- Runtime stage ----
# Sirve los archivos estáticos generados con nginx
FROM nginx:1.27-alpine

COPY --from=build /app/output /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
