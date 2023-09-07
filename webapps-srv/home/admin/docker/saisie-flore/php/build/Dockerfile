FROM php:7.3.33-fpm-bullseye

LABEL maintainer "Jean-Pascal MILCENT <jpm@clapas.org>"

ARG TZ="${TZ:-Europe/Paris}"
ARG POSTGRES_HOST="${POSTGRES_HOST}"
ARG POSTGRES_PORT="${POSTGRES_PORT}"
ARG POSTGRES_DB="${POSTGRES_DB}"
ARG POSTGRES_USER="${POSTGRES_USER}"
ARG POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"
ARG APP_MAILTO="${APP_MAILTO}"
ARG APP_NAME="${APP_NAME}"
ARG APP_REPO="${APP_REPO}"
ARG APP_VERSION="${APP_VERSION}"
ARG APP_VERSION_CHECKSUM="${APP_VERSION_CHECKSUM}"
ARG MSMTP_OVH_HOST="${MSMTP_OVH_HOST}"
ARG MSMTP_OVH_EMAIL="${MSMTP_OVH_EMAIL}"
ARG MSMTP_OVH_PWD="${MSMTP_OVH_PWD}"

ENV TZ ${TZ}
ENV DEFAULT_TZ ${TZ}
ENV APP_PATH /var/www/html
ENV PHP_FPM_CONF_FILEPATH /usr/local/etc/php-fpm.d/zz-docker.conf


# Install system packages and PHP extenssions
RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
		tzdata \
		wget \
        vim \
		msmtp msmtp-mta bsd-mailx mailutils \
		libfcgi-bin \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
		libpq-dev && \
	docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && \
	docker-php-ext-install pdo pdo_pgsql pgsql && \
	docker-php-ext-install -j$(nproc) iconv && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
    apt-get clean autoclean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/{apt,dpkg,cache,log}


# Use the default production configuration
RUN mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"
# Enable Opcache
RUN sed -i "s/^;opcache\.memory_consumption.*$/opcache.memory_consumption=128/" "${PHP_INI_DIR}/php.ini" && \
	sed -i "s/^;opcache\.interned_strings_buffer.*$/opcache.interned_strings_buffer=8/" "${PHP_INI_DIR}/php.ini" && \
	sed -i "s/^;opcache\.max_accelerated_files.*$/opcache.max_accelerated_files=4000/" "${PHP_INI_DIR}/php.ini" && \
	sed -i "s/^;opcache\.revalidate_freq.*$/opcache.revalidate_freq=60/" "${PHP_INI_DIR}/php.ini" && \
	sed -i "s/^;opcache\.enable_cli.*$/opcache.enable_cli=1/" "${PHP_INI_DIR}/php.ini"
# Override php.ini properties for the app
COPY custom.ini "${PHP_INI_DIR}/conf.d/custom.ini"


# Create Msmtp config file
COPY msmtprc.tpl.conf /etc/msmtprc
RUN sed -i "s/\${MSMTP_OVH_HOST}/${MSMTP_OVH_HOST}/g" /etc/msmtprc && \
	sed -i "s/\${MSMTP_OVH_EMAIL}/${MSMTP_OVH_EMAIL}/g" /etc/msmtprc && \
	sed -i "s/\${MSMTP_OVH_PWD}/${MSMTP_OVH_PWD}/g" /etc/msmtprc && \
	chmod 600 /etc/msmtprc && \
	chown www-data:www-data /etc/msmtprc && \
	touch /var/log/msmtp.log && \
	chown www-data:www-data /var/log/msmtp.log


# Set custom timezone
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo "${TZ}" > /etc/timezone

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
    && echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
    && echo "set mouse=" >> /etc/vim/vimrc.local

# Uncomment alias from /root/.bashrc
RUN sed -i -r 's/^# (alias|export|eval)/\1/' /root/.bashrc

# Enable php fpm status page
RUN set -xe && echo "pm.status_path = /status" >> ${PHP_FPM_CONF_FILEPATH}
# Add healthcheck script
COPY ./php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
# Set executable rights
RUN chmod +x /usr/local/bin/php-fpm-healthcheck
# Add healthcheck instructions
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["php-fpm-healthcheck"]

# Set new root directory for the app => NOT WORK !? => Use default path /var/www/html
#RUN set -xe && \
#	echo "chroot=${APP_PATH}" >> ${PHP_FPM_CONF_FILEPATH} && \
#	echo "chdir=/" >> ${PHP_FPM_CONF_FILEPATH}

# Download and deploy the app
WORKDIR /tmp
RUN wget --quiet \
    --output-document app.tar.gz \
    https://github.com/${APP_REPO}/archive/refs/tags/v${APP_VERSION}.tar.gz
#ADD https://github.com/${APP_REPO}/archive/refs/tags/v${APP_VERSION}.tar.gz /tmp

RUN if [ "${APP_VERSION_CHECKSUM}" != "$(md5sum app.tar.gz | awk '{print($1)}')" ];then \
        echo "App ${APP_NAME} archive downloaded file have wrong md5sum !"; \
        exit 1; \
    fi
RUN tar -xf app.tar.gz && rm app.tar.gz && rm -rf "${APP_PATH}/" && mv "${APP_NAME}-${APP_VERSION}/" "${APP_PATH}/"

# Set App configuration file
COPY ./config.default.php ${APP_PATH}/config.php
RUN sed -i "s/\${POSTGRES_HOST}/saisie-flore-postgres/g" ${APP_PATH}/config.php && \
    sed -i "s/\${POSTGRES_PORT}/${POSTGRES_PORT}/g" ${APP_PATH}/config.php && \
    sed -i "s/\${POSTGRES_DB}/${POSTGRES_DB}/g" ${APP_PATH}/config.php && \
    sed -i "s/\${POSTGRES_USER}/${POSTGRES_USER}/g" ${APP_PATH}/config.php && \
    sed -i "s/\${POSTGRES_PASSWORD}/${POSTGRES_PASSWORD}/g" ${APP_PATH}/config.php && \
    sed -i "s/\${APP_MAILTO}/${APP_MAILTO}/g" ${APP_PATH}/config.php

# Set max input file size
RUN sed -i "s/maxFileSize: 2048/maxFileSize: 24576/" ${APP_PATH}/js/init_fileinput.js

# Set default rights on app directory
RUN chown -R www-data: ${APP_PATH}

WORKDIR ${APP_PATH}
