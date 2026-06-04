FROM php:8.4-apache

# Instalar dependencias del sistema (incluye Node.js)
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    zip \
    unzip \
    git \
    curl \
    gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && docker-php-ext-install pdo_sqlite

# Instalar Composer
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Configurar Apache para Laravel
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
RUN a2enmod rewrite

# Cambiar puerto de Apache a 8080 (necesario para Render)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf

WORKDIR /var/www/html

# Copiar todo el código
COPY . .

# Permisos para base de datos y storage
RUN mkdir -p database \
    && touch database/database.sqlite \
    && chown -R www-data:www-data database \
    && chmod -R 775 database \
    && chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Instalar dependencias PHP
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs
RUN php artisan package:discover --ansi || true

# Instalar dependencias Node y compilar assets
RUN npm install --legacy-peer-deps
RUN npm run build

EXPOSE 8080
CMD ["apache2-foreground"]