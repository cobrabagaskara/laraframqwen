#!/bin/bash

echo "🚀 Setting up Laravel for Filament..."

# Install system dependencies
sudo apt-get update
sudo apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    sqlite3 \
    libsqlite3-dev

# Install PHP extensions
sudo docker-php-ext-configure gd --with-freetype --with-jpeg
sudo docker-php-ext-install \
    pdo_sqlite \
    sqlite3 \
    gd \
    zip \
    mbstring \
    xml \
    tokenizer \
    fileinfo

# Install Composer dependencies
if [ -f "composer.json" ]; then
    echo "📦 Installing Composer packages..."
    composer install --no-interaction --prefer-dist --optimize-autoloader
    
    # Setup .env
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            echo "⚙️ Creating .env file..."
            cp .env.example .env
            
            # Configure for SQLite
            sed -i 's/DB_CONNECTION=mysql/DB_CONNECTION=sqlite/' .env
            sed -i 's/DB_DATABASE=.*/DB_DATABASE=database\/database.sqlite/' .env
            sed -i 's/DB_HOST=127.0.0.1/# DB_HOST=127.0.0.1/' .env
            sed -i 's/DB_PORT=3306/# DB_PORT=3306/' .env
            sed -i 's/DB_USERNAME=/# DB_USERNAME=/' .env
            sed -i 's/DB_PASSWORD=/# DB_PASSWORD=/' .env
            
            php artisan key:generate
        fi
    fi
    
    # Create SQLite database
    mkdir -p database
    touch database/database.sqlite
    chmod 755 database
    chmod 644 database/database.sqlite
else
    echo "📁 No composer.json found. Creating new Laravel project..."
    composer create-project laravel/laravel . --prefer-dist
fi

# Set proper permissions
sudo chown -R $(whoami):$(whoami) .
sudo chmod -R 755 storage bootstrap/cache

# Install Node.js dependencies
if [ -f "package.json" ]; then
    echo "📦 Installing Node.js packages..."
    npm install
fi

echo ""
echo "✅ Environment ready for Filament!"
echo ""
echo "📊 PHP Extensions:"
php -m | grep -E "pdo|sqlite|gd|zip|mbstring"
echo ""
echo "🚀 To install Filament:"
echo "   composer require filament/filament"
echo "   php artisan filament:install --panels"
echo ""
echo "🌐 Start server: php artisan serve --host=0.0.0.0 --port=8000"
