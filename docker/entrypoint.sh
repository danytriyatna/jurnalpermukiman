#!/usr/bin/env bash
set -euo pipefail

FILES_DIR="${OJS_FILES_DIR:-/var/www/files_dir}"
mkdir -p \
  "$FILES_DIR" \
  /var/www/html/cache/t_compile \
  /var/www/html/cache/t_cache \
  /var/www/html/cache/_db \
  /var/www/html/public

# Generate config.inc.php dari environment variables jika tidak di-skip/mount read-only
if [ -w /var/www/html ] && { [ ! -e /var/www/html/config.inc.php ] || [ -w /var/www/html/config.inc.php ]; }; then
  php /usr/local/bin/configure-ojs.php
fi

chown -R www-data:www-data "$FILES_DIR" /var/www/html/cache /var/www/html/public

exec apache2-foreground
