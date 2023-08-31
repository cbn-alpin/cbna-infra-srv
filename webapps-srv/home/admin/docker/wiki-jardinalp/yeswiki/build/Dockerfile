FROM php:7.3.33-fpm-bullseye

LABEL maintainer "Jean-Pascal MILCENT <jpm@clapas.org>"

ARG TZ=${TZ:-Europe/Paris}
ARG MARIADB_DB
ARG MARIADB_USER
ARG MARIADB_PASSWORD
ARG YW_NAME
ARG YW_BASE_URL
ARG YW_BACKUP_DATE
ARG YW_DB_TABLE_PREFIX
ARG YW_VERSION_NAME
ARG YW_VERSION_CODE
ARG YW_VERSION_CHECKSUM

ENV DEFAULT_TZ ${TZ}
ENV WWW_PATH /var/www
ENV HTML_PATH /var/www/html


# Install system packages and PHP extenssions
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install \
		wget \
		vim \
		unzip \
		libzip-dev \
		zip \
		libfcgi-bin \
		libfreetype6-dev \
		libjpeg62-turbo-dev \
		libpng-dev && \
	docker-php-ext-install -j$(nproc) iconv && \
	docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
	docker-php-ext-install -j$(nproc) gd && \
	docker-php-ext-install mysqli && \
	docker-php-ext-enable mysqli && \
	docker-php-ext-install mbstring && \
	docker-php-ext-install exif && \
	docker-php-ext-install zip && \
	apt-get clean autoclean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/{apt,dpkg,cache,log}


# Use the default production configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
	&& echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
	&& echo "set mouse=" >> /etc/vim/vimrc.local

# Uncomment alias from /root/.bashrc
RUN sed -i -r 's/^# (alias|export|eval)/\1/' /root/.bashrc

# Enable php fpm status page
RUN set -xe && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf
# Add healthcheck script
COPY ./php-fpm-healthcheck.sh /usr/local/bin/php-fpm-healthcheck
# Set executable rights
RUN chmod +x /usr/local/bin/php-fpm-healthcheck
# Add healthcheck instructions
HEALTHCHECK --interval=10s --timeout=3s --retries=3 CMD ["php-fpm-healthcheck"]


# Download and deploy YesWiki
WORKDIR ${WWW_PATH}
RUN wget --quiet \
	--output-document yeswiki.zip \
	https://repository.yeswiki.net/${YW_VERSION_NAME}/yeswiki-${YW_VERSION_NAME}-${YW_VERSION_CODE}.zip
RUN if [ "${YW_VERSION_CHECKSUM}" != "$(md5sum yeswiki.zip | awk '{print($1)}')" ];then \
		echo "YesWiki downloaded file have wrong md5sum !"; \
		exit 1; \
	fi
RUN rm -rf ${HTML_PATH} && unzip yeswiki.zip && rm yeswiki.zip && mv ${YW_VERSION_NAME} ${HTML_PATH}


# Set YesWiki configuration file
COPY ./wakka.config.php ${HTML_PATH}/wakka.config.php
RUN sed -i "s/\${MARIADB_DB}/${MARIADB_DB}/g" ${HTML_PATH}/wakka.config.php && \
	sed -i "s/\${MARIADB_USER}/${MARIADB_USER}/g" ${HTML_PATH}/wakka.config.php && \
	sed -i "s/\${MARIADB_PASSWORD}/${MARIADB_PASSWORD}/g" ${HTML_PATH}/wakka.config.php && \
	sed -i "s/\${YW_DB_TABLE_PREFIX}/${YW_DB_TABLE_PREFIX}/g" ${HTML_PATH}/wakka.config.php && \
	sed -i "s/\${YW_NAME}/${YW_NAME}/g" ${HTML_PATH}/wakka.config.php && \
	sed -i "s#\${YW_BASE_URL}#${YW_BASE_URL}#g" ${HTML_PATH}/wakka.config.php


# Manage backups
# Copy and unzip content of .tar.bz2 files. Use "*.tar.bz" to avoid error if not exists.
ADD ${YW_BACKUP_DATE}_backup_files_jardinalp_*.tar.bz2 ${HTML_PATH}/
# Copy content of ./themes directorys. Use "...[s]" to avoid error if not exists.
ADD ./theme[s] ${HTML_PATH}/themes/

RUN chown -R www-data: ${HTML_PATH}

WORKDIR ${HTML_PATH}
