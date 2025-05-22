#!/usr/bin/env sh
set -e

echo ">>> Entrypoint: sustituyendo \${PORT} en nginx.conf.template"

# Si PORT no está definida, nombra un valor por defecto (80)
: "${PORT:=80}"

# Reemplaza ${PORT} en la plantilla y genera default.conf
envsubst '$PORT' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf

echo ">>> Entrypoint: finished envsubst, PORT=${PORT}"
echo ">>> Contenido de /etc/nginx/conf.d/default.conf:"
cat /etc/nginx/conf.d/default.conf

# Ejecuta el comando que llegó (CMD)
exec "$@"

