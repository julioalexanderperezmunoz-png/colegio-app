FROM dunglas/frankenphp:php8.4-alpine

# Instalar extensiones necesarias (SQLite)
RUN install-php-extensions pdo_sqlite

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de Composer primero (para optimizar caché)
COPY composer.json composer.lock ./
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Copiar el resto de la aplicación
COPY . .

# Crear directorios y permisos para almacenamiento
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Exponer el puerto (Railway asigna el puerto dinámico en PORT)
EXPOSE ${PORT:-8080}

# Comando para iniciar la aplicación
CMD php artisan migrate --force && \
    php artisan storage:link && \
    php artisan serve --host=0.0.0.0 --port=${PORT:-8080}