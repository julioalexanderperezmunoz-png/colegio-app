FROM dunglas/frankenphp:php8.4-alpine

# Instalar Composer
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Instalar extensiones necesarias
RUN install-php-extensions pdo_sqlite

WORKDIR /app

# Copiar archivos de Composer
COPY composer.json composer.lock ./
RUN composer install --no-interaction --optimize-autoloader --no-dev

# Copiar resto del código
COPY . .

# Crear directorios de almacenamiento
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE ${PORT:-8080}

CMD php artisan migrate --force && \
    php artisan storage:link && \
    php artisan serve --host=0.0.0.0 --port=${PORT:-8080}