FROM php:8.4-cli

RUN apt-get update && apt-get install -y \
    libsqlite3-dev zip unzip git curl \
    && docker-php-ext-install pdo_sqlite

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

COPY --from=composer:2.8 /usr/bin/composer /usr/bin/composer

WORKDIR /app

COPY . .

RUN composer install --no-interaction --optimize-autoloader --no-dev --ignore-platform-reqs

RUN npm install && npm run build

RUN mkdir -p database && touch database/database.sqlite && chmod 777 database database/database.sqlite
RUN chmod -R 777 storage bootstrap/cache

EXPOSE 8080

CMD php artisan migrate --force && php artisan serve --host=0.0.0.0 --port=8080