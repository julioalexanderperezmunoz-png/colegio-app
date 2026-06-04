FROM php:8.4-cli

# Instalar dependencias
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

WORKDIR /var/www/html

# Copiar todo el código
COPY . .

# Instalar dependencias PHP de Composer
RUN composer install --no-interaction --optimize-autoloader --no-dev --no-scripts --ignore-platform-reqs
RUN php artisan package:discover --ansi || true

# Instalar dependencias Node y compilar assets de Vite
RUN npm install && npm run build

# Crear base de datos SQLite y permisos
RUN mkdir -p database \
    && touch database/database.sqlite \
    && chmod -R 777 database

# Dar permisos a storage y bootstrap/cache
RUN chmod -R 777 storage bootstrap/cache

# Exponer el puerto que usa artisan serve (por defecto 8000, pero Render asigna el puerto mediante PORT)
EXPOSE ${PORT:-8080}

# Usar artisan serve, escuchando en todas las interfaces y en el puerto que Render asigna
CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=${PORT:-8080}