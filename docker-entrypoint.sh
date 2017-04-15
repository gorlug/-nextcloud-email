#!/bin/bash
set -e

if cmp -s "/usr/src/nextcloud/version.php" "/var/www/html/version.php"
then
    echo "nothing to do here"
else
    ls /var/www/html | grep -v "data" | grep -v "config" | grep -v "apps" | xargs rm -rf
    rm -f /var/www/html/.htaccess
    rm -f /var/www/html/.user.ini
    rm /var/www/html/apps/logreader/webpack/dev-proxy.js
fi

if [ ! -e '/var/www/html/version.php' ]; then
    tar cf - --one-file-system -C /usr/src/nextcloud . | tar xf -
    chown -R www-data /var/www/html
    chmod +x /var/www/html/occ
fi
if [ ! -e '/var/www/html/config/config.php' ]; then
    echo "waiting for database connection"
    sleep 30
    mysql -uroot -p${MYSQL_ROOT_PASSWORD} -hdb -e "create database if not exists nextcloud;"
    su www-data -c "/var/www/html/occ maintenance:install --database mysql --database-host db --database-name nextcloud --database-user root --database-pass \"${MYSQL_ROOT_PASSWORD}\" --admin-user \"${NEXTCLOUD_ADMIN_USER}\" --admin-pass \"${NEXTCLOUD_ADMIN_PASSWORD}\""
    su www-data -c "/var/www/html/occ config:system:set trusted_domains 0 --value ${CLOUD_HOSTNAME}"
    su www-data -c "/var/www/html/occ app:enable user_external"
    su www-data -c "/var/www/html/occ config:system:set user_backends 0 class --value \"OC_User_IMAP\""
    su www-data -c "/var/www/html/occ config:system:set user_backends 0 arguments 0 --value {dovecot:993/imap/ssl/novalidate-cert}"
    su www-data -c "/var/www/html/occ config:system:set overwritewebroot --value /cloud"
    rm /var/www/html/data/nextcloud.log
    ln -s /dev/stderr /var/www/html/data/nextcloud.log
else
    su www-data -c "/var/www/html/occ upgrade -n --no-app-disable --no-warnings" || true
fi

php-fpm
