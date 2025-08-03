FROM php:8.1-apache

# Install system dependencies and PHP extensions needed for Laravel & SQLite
RUN apt-get update && apt-get install -y \
    sqlite3 libsqlite3-dev unzip curl \
    && docker-php-ext-install pdo pdo_sqlite

# Enable Apache rewrite module for Laravel routing
RUN a2enmod rewrite

# Set working directory
WORKDIR /var/www/html

# Copy Laravel app code into container
COPY . .

# Change Apache DocumentRoot to Laravel's public folder
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf

# Fix permissions for Laravel folders
RUN chown -R www-data:www-data storage bootstrap/cache database

# Install composer and dependencies
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

# Cache config, routes, views for performance
RUN php artisan config:cache \
 && php artisan route:cache \
 && php artisan view:cache

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start Apache in foreground
CMD ["apache2-foreground"]
