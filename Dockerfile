FROM php:8.4-apache

# Instalar dependencias del sistema y extensiones
RUN apt-get update && apt-get install -y \
    libsqlite3-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_sqlite

# Instalar Node.js 20 LTS (necesario para Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Instalar Composer
COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

# Configurar Apache: DocumentRoot a /var/www/html/public
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Habilitar mod_rewrite y mod_headers
RUN a2enmod rewrite headers

# Cambiar el puerto de Apache al que Render usa (8080)
RUN sed -i 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Copiar todo el código
COPY . .

# Dar permisos a la carpeta public y storage
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Permisos especiales para el directorio public (asegurar que index.php es legible)
RUN chown -R www-data:www-data public \
    && chmod -R 755 public

# Crear base de datos SQLite y dar permisos
RUN mkdir -p database \
    && touch database/database.sqlite \
    && chown -R www-data:www-data database \
    && chmod -R 775 database

# Instalar dependencias PHP de Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs

# Ejecutar scripts de Laravel
RUN php artisan package:discover --ansi || true

# Instalar dependencias Node y compilar assets de Vite
RUN npm install && npm run build

EXPOSE 8080

CMD ["apache2-foreground"]