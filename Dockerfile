FROM indiehosters/nextcloud
MAINTAINER Achim Rohn <achim@rohn.eu>

RUN apt-get update && apt-get install -y \
  libc-client2007e-dev \
  libkrb5-dev \
  && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
  && docker-php-ext-install imap
RUN usermod -s /bin/bash www-data

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
