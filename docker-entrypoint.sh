#!/bin/bash
set -e

if [ ! -e '/var/www/html/version.php' ]; then
    tar cf - --one-file-system -C /usr/src/nextcloud . | tar xf -
    chown -R www-data /var/www/html
    chmod +x /var/www/html/occ
    su www-data -c "/var/www/html/occ maintenance:install --database mysql --database-host db --database-name nextcloud --database-user root --database-pass \"${MYSQL_ROOT_PASSWORD}\" --admin-user \"${NEXTCLOUD_ADMIN_USER}\" --admin-pass \"${NEXTCLOUD_ADMIN_PASSWORD}\""
    su www-data -c "/var/www/html/occ config:system:set trusted_domains 0 --value ${HOSTNAME}"
    su www-data -c "/var/www/html/occ app:enable user_external"
    su www-data -c "/var/www/html/occ config:system:set user_backends 0 class --value \"OC_User_IMAP\""
    su www-data -c "/var/www/html/occ config:system:set user_backends 0 arguments 0 --value {dovecot:993/imap/ssl/novalidate-cert}"
fi

exec "$@"
