This docker image is intended to work laravel projects, running on nginx server.

Features:
* Features included from the [Docker Official Images](https://hub.docker.com/_/php):
    * Based on PHP 7.3 fpm

# Sample Docker compose file

```yaml
version: '3.6'
services:

  app:
    container_name: app
    image: rifkyfuady/php-7.3-fpm
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: app
      SERVICE_TAGS: dev
    working_dir: /var/www
    volumes:
      - ./project:/var/www
```

# My notes :
- docker build --tag rifkyfuady/php-7.3-fpm .
- docker run --rm -v $(pwd):/app composer install
- sudo chown -R $USER:$USER ~/project
- nano ~/project/docker-compose.yml
- docker-compose exec ${APP}srvc php artisan key:generate
- docker-compose exec ${APP}srvc php artisan config:cache
- docker-compose exec ${APP}srvc php artisan migrate
- docker-compose exec ${APP}srvc php artisan db:seed

```yaml
version: '3.6'
services:

  ${APP}:
    container_name: ${APP}
    image: rifkyfuady/php-7.3-fpm
    restart: unless-stopped
    tty: true
    environment:
      SERVICE_NAME: ${APP}srvc
    working_dir: /var/www
    volumes:
      - ${APP_LOC}:/var/www
    networks:
      - ${APP}-network

  ${APP}nginx:
    image: nginx:alpine
    container_name: ${APP}nginx
    restart: unless-stopped
    tty: true
    volumes:
      - ${APP_LOC}:/var/www
      - ./nginx/conf.d/:/etc/nginx/conf.d/
    labels:
      - traefik.enable=true
      - traefik.frontend.rule=Host:${TREAFIK_HOST}
      - traefik.port=${NGINX_PORT}
      - traefik.docker.network=web
    networks:
      - web
      - ${APP}-network

  ${APP}mysql:
    image: mysql
    container_name: ${APP}mysql
    restart: unless-stopped
    command: --default-authentication-plugin=mysql_native_password
    tty: true
    environment:
        MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
        MYSQL_DATABASE: ${MYSQL_DATABASE}
        MYSQL_USER: ${MYSQL_USER}
        MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes:
      - ${APP}db:/var/lib/mysql
      - ./mysql/my.cnf:/etc/mysql/my.cnf
    networks:
      - ${APP}-network

  ${APP}phpmyadmin:
    container_name: ${APP}phpmyadmin
    image: phpmyadmin/phpmyadmin
    restart: unless-stopped
    ports:
      - "${PHPMYADMIN_PORT}:80"
    links:
      - ${APP}mysql:db
    networks:
      - ${APP}-network

networks:
  web:
    external: true
  ${APP}-network:
    driver: bridge

volumes:
  ${APP}db:
    driver: local
```