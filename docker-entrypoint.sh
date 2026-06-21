#!/bin/sh
# ============================================================
#  Inyeccion de URLs de backend en runtime
#  Reemplaza los placeholders __BACKEND_*__ que quedaron
#  horneados en script.js por los valores de las variables
#  de entorno definidas en la Task Definition de ECS.
# ============================================================
set -e

: "${BACKEND_USERS_URL:=http://localhost:8081}"
: "${BACKEND_PRODUCTS_URL:=http://localhost:8082}"

JS_FILE=/usr/share/nginx/html/script.js

if [ -f "$JS_FILE" ]; then
  sed -i \
    -e "s|__BACKEND_USERS_URL__|${BACKEND_USERS_URL}|g" \
    -e "s|__BACKEND_PRODUCTS_URL__|${BACKEND_PRODUCTS_URL}|g" \
    "$JS_FILE"
  echo "[entrypoint] Front configurado -> USERS=${BACKEND_USERS_URL} | PRODUCTS=${BACKEND_PRODUCTS_URL}"
else
  echo "[entrypoint] ADVERTENCIA: no se encontro $JS_FILE"
fi
