# Custom Email Addon for Pterodactyl Panel

A community addon installer for Pterodactyl Panel that adds an **Email Utils** item to the administrator menu and integrates the addon's email-template handling with the account-created notification.

> **Important:** This is an unofficial modification to Pterodactyl Panel files. The installer edits core files in place and does not create a backup automatically. Back up your Panel files and database before installing, and test on a staging panel first.

## Features installed by this script

- Adds an **Email Utils** item to the admin navigation.
- Registers `EmailUtilsServiceProvider` in `config/app.php`.
- Copies addon files from the `Mail.zip` release into the Panel's `app`, `config`, `database`, `public`, `resources`, and `routes` directories.
- Updates the `AccountCreated` notification to integrate the email-template manager.
- Clears Laravel/Pterodactyl caches and runs database migrations and seeders.

The script does not configure your SMTP credentials. Pterodactyl's mail transport must already be configured correctly for your environment.

## Requirements

- A working Pterodactyl Panel installation.
- The Panel installed at `/var/www/pterodactyl` (this path is hard-coded in the script).
- A Debian/Ubuntu-style system with `apt`, `sudo`, Bash, `wget`, PHP, and the Panel's normal dependencies.
- Root/sudo access and a working internet connection.
- A Panel version whose core files are compatible with this addon. **The installer does not check the Panel version**, so compatibility is not guaranteed by the script.

## Before installing: create backups

Run these commands on the Panel server. They create a timestamped backup of the Panel directory and a database export. The database command below assumes your Panel uses MySQL/MariaDB; adjust the database name and credentials for your installation.

```bash
cd /var/www/pterodactyl

# Back up the Panel files (including .env)
sudo tar -czf "/root/pterodactyl-files-$(date +%F-%H%M%S).tar.gz" -C /var/www pterodactyl

# Read your database settings from .env before running the dump
sudo grep -E '^(DB_HOST|DB_PORT|DB_DATABASE|DB_USERNAME)=' .env
```

Then export your database using the database name and username shown in `.env`:

```bash
mysqldump -u YOUR_DB_USERNAME -p YOUR_DB_DATABASE > "$HOME/pterodactyl-db-$(date +%F-%H%M%S).sql"
```

Enter the database password when prompted. Keep these backups private because the files archive contains `.env`, which can include application keys and credentials.

## One-command installation

Review the installer source before running it:

- [Installer script](https://github.com/amitbhai51-c/Custom-Email/blob/main/main)
- [Mail release](https://github.com/amitbhai51-c/Custom-Email/releases/tag/Mail)

To download and run the current installer from the repository's `main` branch:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/amitbhai51-c/Custom-Email/main/main)
```

The script uses `sudo` internally. Follow any password prompt. It downloads `Mail.zip`, copies files into `/var/www/pterodactyl`, edits Panel files, clears caches, fixes ownership to `www-data:www-data`, and runs `php artisan migrate --seed --force`.

### Safer alternative: download, inspect, then run

This lets you inspect the script before executing it:

```bash
curl -fL \
  https://raw.githubusercontent.com/amitbhai51-c/Custom-Email/main/main \
  -o install-custom-email.sh

less install-custom-email.sh
bash install-custom-email.sh
```

## After installation

1. Open the Pterodactyl Panel in your browser and sign in with an administrator account.
2. Look for **Email Utils** in the admin navigation.
3. Configure and test the email-related settings provided by the addon.
4. Confirm Pterodactyl's general mail configuration works. The official setup guide documents the Panel mail configuration commands: [Pterodactyl Getting Started](https://pterodactyl.io/panel/1.0/getting_started.html).

You can clear the Panel caches manually if needed:

```bash
cd /var/www/pterodactyl
php artisan optimize:clear
php artisan view:clear
php artisan config:clear
php artisan cache:clear
```

## Troubleshooting

### `No such file or directory: /var/www/pterodactyl`

The installer expects the Panel at `/var/www/pterodactyl`. If your Panel is installed elsewhere, do not run this script as-is; update and review the hard-coded paths first.

### `wget`, `unzip`, or download errors

Check network access and verify that the [Mail release](https://github.com/amitbhai51-c/Custom-Email/releases/tag/Mail) contains `Mail.zip`. The installer currently does not stop immediately on every failed command, so read its output carefully and check that the archive downloaded and extracted correctly.

### `Email Utils` is missing or the Panel shows an error

Run the following commands and inspect the output:

```bash
cd /var/www/pterodactyl
php artisan optimize:clear
php artisan route:list | grep -i email
sudo tail -n 100 /var/log/nginx/error.log
```

If your server uses Apache or a different web-server log path, check that server's error log instead. Also check the Panel's `storage/logs` directory. Do not repeatedly rerun the installer to try to fix a broken installation; restore your backups or investigate the specific error first.

### Email is not being delivered

This addon does not replace the Panel's SMTP configuration. Verify the mail host, port, encryption, username, password, and sender address in the Panel's environment configuration. Check your mail provider's logs and the Panel logs for delivery errors.

## Important installer limitations

Please be aware of the following behavior in the current script:

- It overwrites/copies files into several core Panel directories.
- It modifies `config/app.php`, `resources/views/layouts/admin.blade.php`, and `app/Notifications/AccountCreated.php` using text substitutions that depend on the original file contents.
- It does not verify the downloaded ZIP with a checksum or signature before extraction.
- It does not automatically back up modified files or the database.
- It runs `php artisan migrate --seed --force` and recursively changes ownership of the Panel directory to `www-data:www-data`.
- It assumes a Debian/Ubuntu-like environment and a `www-data` web-server user.
- Its success message alone does not prove every installation step completed successfully.

Use a maintenance window and keep a working backup. For production systems, review the installer and release contents before executing them as root.

## Links

- **Repository:** https://github.com/amitbhai51-c/Custom-Email
- **Installer source:** https://github.com/amitbhai51-c/Custom-Email/blob/main/main
- **Release:** https://github.com/amitbhai51-c/Custom-Email/releases/tag/Mail
- **Pterodactyl Panel documentation:** https://pterodactyl.io/panel/1.0/getting_started.html

## License

Check the repository and release for the applicable license and third-party notices before redistribution. No license terms are asserted here.
