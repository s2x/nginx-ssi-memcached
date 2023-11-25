FROM golang:alpine AS golang_build
RUN apk add --no-cache --update git && \
    git clone https://github.com/ochinchina/supervisord.git && \
    cd supervisord && \
    GOOS=linux go build -a -ldflags '-s -w' -o /usr/local/bin/supervisord github.com/ochinchina/supervisord
COPY http-server-go /tmp/http-server-go
RUN cd /tmp/http-server-go && \
    GOOS=linux go build -a -ldflags '-s -w' -o /usr/local/bin/http-server-go

FROM alpine AS composer
RUN apk add --no-cache wget php82 php82-openssl php82-phar php82-iconv && \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php82 -- --quiet && \
    mv composer.phar /usr/bin/composer

FROM alpine:3.18
RUN apk add --no-cache php82-fpm php82-curl php82-iconv php82-mbstring php82-openssl \
    php82-zip php82-phar php82-ctype php82-xml php82-session php82-dom php82-intl \
    php82-tokenizer php82-opcache php82-xmlwriter php82-simplexml php82-pecl-memcached \
    nginx nginx-mod-http-lua memcached && \
    ln -s /usr/bin/php82 /usr/bin/php

COPY --from=golang_build /usr/local/bin/supervisord /usr/bin/supervisord
COPY --from=golang_build /usr/local/bin/http-server-go /usr/bin/http-server-go
COPY --from=composer /usr/bin/composer /usr/bin/composer
COPY config/etc /etc
COPY config/usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY symfony /var/www
WORKDIR /var/www
RUN composer i && composer clear-cache && ./bin/console c:w
CMD ["/usr/local/bin/entrypoint.sh"]
