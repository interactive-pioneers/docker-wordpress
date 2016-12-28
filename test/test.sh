#!/bin/bash

set -e

# Config
declare -a filepaths=(
  /var/www/html/index.php
  /var/www/html/license.txt
  /var/www/html/liesmich.html
  /var/www/html/wp-activate.php
  /var/www/html/wp-admin
  /var/www/html/wp-blog-header.php
  /var/www/html/wp-comments-post.php
  /var/www/html/wp-config-sample.php
  /var/www/html/wp-content
  /var/www/html/wp-cron.php
  /var/www/html/wp-includes
  /var/www/html/wp-links-opml.php
  /var/www/html/wp-load.php
  /var/www/html/wp-login.php
  /var/www/html/wp-mail.php
  /var/www/html/wp-settings.php
  /var/www/html/wp-signup.php
  /var/www/html/wp-trackback.php
  /var/www/html/xmlrpc.php
  /var/www/html/wp-content/languages/de_DE.mo
  /var/www/html/wp-content/languages/de_DE.po
  /var/www/html/wp-content/plugins/regenerate-thumbnails
  /var/www/html/wp-content/plugins/timber-library
  /var/www/html/wp-content/plugins/wp-nested-pages
)

# Universal tests
printf "\nTesting web\n "

printf "\n\nChecking filepaths...\n"
for filepath in "${filepaths[@]}"
do
  docker-compose exec web test -e $filepath \
    && printf "\n$filepath found." \
    || (printf "\n$filepath not found! Test failed."; exit 1)
done

printf "\n\nChecking HTTP response..."
response=$(docker-compose exec web curl -I http://localhost 2>/dev/null | head -n 1 | cut -d$' ' -f2)
[ "$response" == "302" ] && printf "\nResponse OK" || (printf "\nResponse failure ($response)! Test failed.\n"; exit 1)

printf "\nChecking Unzip...\n"
docker-compose run web bash -lc "unzip -v" || (printf "\nUnzip not found! Test failed.\n"; exit 1)

printf "\nChecking Sudo...\n"
docker-compose run web bash -lc "sudo -V" || (printf "\nSudo not found! Test failed.\n"; exit 1)

printf "\nChecking Node...\n"
docker-compose run web bash -lc "node -v" || (printf "\nNode not found! Test failed.\n"; exit 1)

printf "\nweb test complete. All tests successful.\n"
