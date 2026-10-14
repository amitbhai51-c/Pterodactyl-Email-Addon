#!/bin/bash

clear
echo "| Made by --> Amitbhai51 |"

sleep 3

sudo su <<'EOF'

cd /var/www/pterodactyl || exit

wget -O Mail.zip https://github.com/amitbhai51-c/Custom-Email/releases/download/Mail/Mail.zip

apt install unzip -y

unzip -o Mail.zip

cp -r app/* /var/www/pterodactyl/app/
cp -r config/* /var/www/pterodactyl/config/
cp -r database/* /var/www/pterodactyl/database/
cp -r public/* /var/www/pterodactyl/public/
cp -r resources/* /var/www/pterodactyl/resources/
cp -r routes/* /var/www/pterodactyl/routes/

echo "Registering Email Utils Service Provider..."

APP_FILE="/var/www/pterodactyl/config/app.php"

if ! grep -q "EmailUtilsServiceProvider" "$APP_FILE"; then
    sed -i '/Pterodactyl\\Providers\\ViewComposerServiceProvider::class,/a\    Pterodactyl\\Providers\\EmailUtilsServiceProvider::class,' "$APP_FILE"
fi

echo "Adding Email Utils menu..."

ADMIN_FILE="/var/www/pterodactyl/resources/views/layouts/admin.blade.php"

if ! grep -q "admin.email-utils" "$ADMIN_FILE"; then
    sed -i "/<li class=\"{{ ! starts_with(Route::currentRouteName(), 'admin.api') ?: 'active' }}\">/i\    <li class=\"{{ ! starts_with(Route::currentRouteName(), 'admin.email-utils') ?: 'active' }}\">\n        <a href=\"{{ route('admin.email-utils') }}\">\n            <i class=\"fa fa-envelope\"></i> <span>Email Utils</span>\n        </a>\n    </li>" "$ADMIN_FILE"
fi

echo "Updating AccountCreated notification..."

ACCOUNT_FILE="/var/www/pterodactyl/app/Notifications/AccountCreated.php"

if ! grep -q "EmailTemplateManager" "$ACCOUNT_FILE"; then
    sed -i '/use Illuminate\\Notifications\\Messages\\MailMessage;/a\use Pterodactyl\\Services\\EmailUtils\\EmailTemplateManager;' "$ACCOUNT_FILE"
fi

sed -i 's/public function toMail(): MailMessage/public function toMail(mixed \$notifiable = null): MailMessage/g' "$ACCOUNT_FILE"

sed -i "s@return \$message->action('Setup Your Account', url('/auth/password/reset/' \. \$this->token \. '?email=' \. urlencode(\$this->user->email)));@\\$message->action('Setup Your Account', url('/auth/password/reset/' . \$this->token . '?email=' . urlencode(\$this->user->email)));@g" "$ACCOUNT_FILE"
sleep 2
clear
echo "Running final artisan commands..."
sleep 2
cd /var/www/pterodactyl

php artisan optimize:clear

php artisan view:clear

php artisan config:clear

php artisan cache:clear

chmod -R 755 storage bootstrap/cache

chown -R www-data:www-data /var/www/pterodactyl

php artisan migrate --seed --force

echo ""
echo "========================================"
echo "Pterodactyl Email Utils Installed!"
echo "========================================"

EOF
