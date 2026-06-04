FROM php:8.4-apache

# Instalar extensiones necesarias (SQLite, etc.)
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    && docker-php-ext-install pdo_sqlite

# Instalar Composer
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Configurar el DocumentRoot de Apache a la carpeta public de Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Habilitar mod_rewrite para Laravel
RUN a2enmod rewrite

WORKDIR /var/www/html

# Copiar todo el código
COPY . .

# Instalar dependencias de Composer (sin scripts para evitar errores)
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts

# Ejecutar scripts manualmente después de la instalación
RUN php artisan package:discover --ansi

# Crear directorios y permisos
RUN mkdir -p storage/framework/{sessions,views,cache} \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Exponer el puerto 8080 (Railway usa este puerto por defecto)
EXPOSE 8080

# Usar Apache en lugar de artisan serve (más estable)
CMD ["apache2-foreground"]