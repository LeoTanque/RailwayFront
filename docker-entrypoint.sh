#!/usr/bin/env sh
set -e

# 1) Sustituir ${PORT} en la plantilla y generar default.conf
envsubst '$PORT' < /etc/nginx/conf.d/nginx.conf.template > /etc/nginx/conf.d/default.conf

# 2) Ejecutar el comando que se pasa al contenedor (CMD)
exec "$@"
