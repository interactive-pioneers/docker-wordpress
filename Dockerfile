FROM php:7.1-apache

MAINTAINER Georg Meyer <gm@interactive-pioneers.de>

# utilities
RUN apt-get update \
  && apt-get install -y build-essential sudo unzip

# node
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -y nodejs

# mysqli
RUN docker-php-ext-install mysqli

# Create user account
ENV USERNAME deploy
ENV HOME /home/$USERNAME
RUN adduser --home $HOME --disabled-password --gecos '' $USERNAME
RUN mkdir -p $HOME/.ssh && touch $HOME/.ssh/known_hosts \
  && chown -R deploy:deploy $HOME/.ssh
RUN echo "%$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN usermod -a -G www-data deploy

# Wordpress
WORKDIR /tmp
ENV HTDOCS /var/www/html
ENV WP_VERSION 4.7.5
ENV WP_LANG de
ENV WP_LOCALE de_DE
RUN curl -sSL https://${WP_LANG}.wordpress.org/wordpress-${WP_VERSION}-${WP_LOCALE}.tar.gz | tar xz
RUN rm -rf \
  wordpress/wp-content/themes/* \
  wordpress/wp-content/plugins/* \
  wordpress/readme.html
RUN rm -rf ${HTDOCS}/* \
  && cp -R /tmp/wordpress/* ${HTDOCS}/
RUN rm -rf /tmp/wordpress

# Wordpress plugins
ENV WP_PLUGINS wp-nested-pages.1.7.1 timber-library.1.2.4 regenerate-thumbnails
RUN for PLUGIN in ${WP_PLUGINS}; do \
  curl -sSL https://downloads.wordpress.org/plugin/${PLUGIN}.zip > /tmp/${PLUGIN}.zip \
  && unzip -q -o /tmp/${PLUGIN}.zip -d ${HTDOCS}/wp-content/plugins/; \
done
WORKDIR $HOME

# run
USER $USERNAME
CMD ["sudo", "apache2-foreground"]
