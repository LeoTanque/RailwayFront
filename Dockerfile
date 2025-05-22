FROM node:20-alpine AS build
WORKDIR /app

# 1.1) Copiar package.json y package-lock.json e instalar dependencias
COPY package.json package-lock.json ./
RUN npm ci

# 1.2) Copiar el resto del código fuente y compilar para producción
COPY . .
RUN npm run build -- --configuration production

# ───────────────────────────────────────────────────────────────────────────────
# 2) STAGE DE PRODUCCIÓN: servir los archivos estáticos con Nginx
# ───────────────────────────────────────────────────────────────────────────────
FROM nginx:1.27-alpine

# 2.1) Instalar gettext para tener envsubst
RUN apk add --no-cache gettext

# 2.2) Eliminar la configuración por defecto de Nginx
RUN rm /etc/nginx/conf.d/default.conf

# 2.3) Copiar plantilla de configuración de Nginx
COPY nginx.conf.template /etc/nginx/conf.d/nginx.conf.template

# 2.4) Copiar los archivos compilados de Angular desde el “build stage”
COPY --from=build /app/dist/aprendiendo/browser /usr/share/nginx/html

# 2.5) Copiar script de entrypoint y darle permisos de ejecución
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 2.6) Exponer solo de referencia el puerto 80 (Railway usará la variable $PORT)
EXPOSE 80

# 2.7) Usar el entrypoint que reemplaza ${PORT} y luego arranca Nginx
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]



