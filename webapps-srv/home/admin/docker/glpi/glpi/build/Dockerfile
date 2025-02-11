#Based Image
FROM php:8.1.22-fpm-bookworm

LABEL maintainer "Jean-Pascal MILCENT <jpm@clapas.org>"

ARG TZ=${TZ:-Europe/Paris}
ARG APP_NAME=${APP_NAME:-'glpi'}
ARG APP_VERSION
ARG APP_DOWNLOAD_URL
ARG APP_MD5_CHECKSUM
ARG APP_PATH=${APP_PATH:-'/app'}
ARG PLUGIN_FI_VERSION
ARG PLUGIN_FI_DOWNLOAD_URL
ARG DB_HOST
ARG DB_NAME
ARG DB_USER
ARG DB_PASSWORD

ENV DEFAULT_TZ ${TZ}
ENV APP_NAME ${APP_NAME}
ENV APP_VERSION ${APP_VERSION}
ENV APP_PATH ${APP_PATH}

# Install system packages
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install \
		vim \
		wget \
		bzip2 \
		unzip \
		cron \
		libfcgi-bin && \
	apt-get clean autoclean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/{apt,dpkg,cache,log}

# Install additonnal PHP module wiht docker-php-extension-installer
# See: https://github.com/mlocati/docker-php-extension-installer
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/

RUN chmod +x /usr/local/bin/install-php-extensions && \
	install-php-extensions \
		apcu \
		bz2 \
		exif \
		gd \
		imap \
		intl \
		ldap \
		mysqli \
		opcache \
		pdo_mysql \
		snmp \
		soap \
		xmlrpc \
		zip

# Use the default production configuration
RUN mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"
# Override php.ini properties for the app
COPY custom.ini /usr/local/etc/php/conf.d/custom.ini

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

# Copy some template files needed for the app
COPY *.tpl.php /tmp/

# Install or update app
WORKDIR /tmp
SHELL ["/bin/bash", "-c"]
RUN wget -q -O ${APP_NAME}.tgz ${APP_DOWNLOAD_URL}
RUN if [ "${APP_MD5_CHECKSUM}" != "$(md5sum ${APP_NAME}.tgz | awk '{print($1)}')" ];then \
		echo "${APP_NAME} downloaded file have wrong md5sum !"; \
		exit 1; \
	fi
RUN tar zxvf ${APP_NAME}.tgz && \
	rm -f ${APP_NAME}.tgz && \
	mkdir -p ${APP_PATH}/${APP_NAME} && \
	'cp' --archive --force ${APP_NAME}/* ${APP_PATH}/${APP_NAME}/ && \
	mkdir -p ${APP_PATH}/log && \
	mkdir -p ${APP_PATH}/data && \
	mkdir -p ${APP_PATH}/config && \
	mv ${APP_PATH}/${APP_NAME}/files ${APP_PATH}/data/files && \
	'cp' --force /tmp/downstream.tpl.php ${APP_PATH}/${APP_NAME}/inc/downstream.php && \
	sed -i "s#\${APP_PATH}#${APP_PATH}#g" ${APP_PATH}/${APP_NAME}/inc/downstream.php && \
	'cp' --force /tmp/local_define.tpl.php ${APP_PATH}/config/local_define.php && \
	sed -i "s#\${APP_PATH}#${APP_PATH}#g" ${APP_PATH}/config/local_define.php

RUN cd ${APP_PATH}/${APP_NAME}/plugins/ && \
	wget -q -O fusioninventory.zip ${PLUGIN_FI_DOWNLOAD_URL} && \
	unzip fusioninventory.zip && \
	rm -f fusioninventory.zip

# Set correct permissions for app files and directories
RUN find ${APP_PATH}/ -type d -exec chmod 755 {} \; && \
	find ${APP_PATH}/ -type f -exec chmod 644 {} \; && \
	chown -R www-data: ${APP_PATH}

# Set Cron for app
COPY glpi.cron /etc/cron.d/glpi
RUN sed -i "s#\${APP_NAME}#${APP_NAME}#g" /etc/cron.d/glpi && \
	sed -i "s#\${APP_PATH}#${APP_PATH}#g" /etc/cron.d/glpi

# Change root directory for App Php-Fpm
RUN echo "chdir = ${APP_PATH}" >> /usr/local/etc/php-fpm.d/www.conf

# Copy entrypoint script make it as executable and run it.
# Entypoint script upgade the app files in named Volume
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && \
	sed -i "s#\${APP_NAME}#${APP_NAME}#g" /usr/local/bin/entrypoint.sh && \
	sed -i "s#\${APP_PATH}#${APP_PATH}#g" /usr/local/bin/entrypoint.sh && \
	sed -i "s#\${DB_HOST}#${DB_HOST}#g" /usr/local/bin/entrypoint.sh && \
	sed -i "s#\${DB_NAME}#${DB_NAME}#g" /usr/local/bin/entrypoint.sh && \
	sed -i "s#\${DB_USER}#${DB_USER}#g" /usr/local/bin/entrypoint.sh && \
	sed -i "s#\${DB_PASSWORD}#${DB_PASSWORD}#g" /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh", "docker-php-entrypoint"]
#ENTRYPOINT [ "/bin/bash", "-c", "source ~/.bashrc && /opt/entrypoint.sh ${@}", "--" ]

WORKDIR ${APP_PATH}
CMD ["php-fpm"]
