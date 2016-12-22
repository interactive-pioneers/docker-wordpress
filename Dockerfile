FROM php:7.1-apache

# node
RUN apt-get update
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash - \
  && apt-get install -y build-essential nodejs sudo

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
ENV WP_VERSION 4.5.3
ENV WP_LANG de
ENV WP_LOCALE de_DE
RUN curl -sSL https://${WP_LANG}.wordpress.org/wordpress-${WP_VERSION}-${WP_LOCALE}.tar.gz | tar xz
RUN rm -rf ${HTDOCS}/*
RUN mv /tmp/wordpress ${HTDOCS}
RUN rm -rf \
      ${HTDOCS}/wp-content/themes/* \
      ${HTDOCS}/wp-content/plugins/* \
      ${HTDOCS}/readme.html

# Wordpress plugins
#ENV WP_PLUGINS wp-nested-pages.1.5.4 timber-library.1.0.4 regenerate-thumbnails
#RUN for PLUGIN in ${WP_PLUGINS}; do \
#      curl -sSL https://downloads.wordpress.org/plugin/${PLUGIN}.zip > /tmp/${PLUGIN}.zip \
#      && unzip -q -o /tmp/${PLUGIN}.zip -d ${HTDOCS}/wp-content/plugins/; \
#    done
WORKDIR $HOME

# run
USER $USERNAME
CMD ["sudo", "apache2-foreground"]
