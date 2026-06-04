FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo_sqlite

COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

WORKDIR /var/www/html

COPY . .

# Asegurar que la base de datos y sus directorios tengan permisos de escritura
RUN mkdir -p database \
    && touch database/database.sqlite \
    && chown -R www-data:www-data database \
    && chmod -R 775 database \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Instalar dependencias de Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Ejecutar scripts manuales
RUN php artisan package:discover --ansi || true

EXPOSE 8080

CMD ["apache2-foreground"]