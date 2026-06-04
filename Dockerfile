FROM php:8.4-apache

# Instalar dependencias del sistema y extensiones
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo_sqlite

# Instalar Composer desde su imagen oficial
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Configurar Apache para Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

WORKDIR /var/www/html

# Copiar todo el código
COPY . .

# Instalar dependencias de Composer sin scripts y sin verificar plataformas
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Ejecutar scripts manualmente (ignorando errores si fallan)
RUN php artisan package:discover --ansi || true

# Crear directorios y establecer permisos
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 8080

CMD ["apache2-foreground"]