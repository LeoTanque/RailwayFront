# ───────────────────────────────────────────────────────────────────────────────
# 1) STAGE DE BUILD: usa Node para compilar tu Angular a producción
# ───────────────────────────────────────────────────────────────────────────────
FROM node:20-alpine AS build

WORKDIR /app

# 1.1) Copia package.json y package-lock.json para aprovechar cache de npm
COPY package.json package-lock.json ./

# 1.2) Instala dependencias (sin versiones globales innecesarias)
RUN npm ci

# 1.3) Copia todo el código fuente al contenedor
COPY . .

# 1.4) Compila para producción (output queda en dist/<project-name>)
#      Asegúrate de que en angular.json, "outputPath" apunte a "dist/aprendiendo/browser"
RUN npm run build -- --configuration production


# ───────────────────────────────────────────────────────────────────────────────
# 2) STAGE DE PRODUCCIÓN: con Nginx sirve los archivos estáticos
# ───────────────────────────────────────────────────────────────────────────────
FROM nginx:1.27-alpine

# 2.1) Elimina la configuración por defecto de Nginx (opcional, si la vas a reemplazar)
RUN rm /etc/nginx/conf.d/default.conf

# 2.2) Copia tu nginx.conf personalizado
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 2.3) Copia los archivos compilados por Angular desde el stage "build"
#      Aquí usamos exactamente la ruta que tu Angular usa como outputPath:
COPY --from=build /app/dist/aprendiendo/browser /usr/share/nginx/html

# 2.4) (opcional) muestra contenido para depurar que realmente se copiaron los archivos
RUN ls -lah /usr/share/nginx/html

# 2.5) Expone el puerto 80 que Nginx usa por defecto
EXPOSE 80

# 2.6) Inicia Nginx en primer plano (modo “daemon off” para que el contenedor no se detenga)
CMD ["nginx", "-g", "daemon off;"]
