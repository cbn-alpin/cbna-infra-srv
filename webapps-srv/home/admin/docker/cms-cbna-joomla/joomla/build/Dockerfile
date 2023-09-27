FROM joomla:3.10.11-php7.4-fpm
#FROM joomla:3.10.12-php8.0-fpm
# https://hub.docker.com/_/joomla

LABEL maintainer "Jean-Pascal MILCENT <jpm@clapas.org>"

ARG TZ=${TZ:-Europe/Paris}
ARG JOOMLA_BACKUP_DATE

ENV DEFAULT_TZ ${TZ}
ENV JOOMLA_PATH /usr/src/joomla

# Install system packages
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install \
		vim \
		libfcgi-bin && \
	apt-get clean autoclean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/{apt,dpkg,cache,log}

# Override upload properties to php.ini
COPY custom.ini ${PHP_INI_DIR}/conf.d/

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

# Manage backups
# Copy and unzip content of .tar.bz2 files. Use "*.tar.bz2" to avoid error if not exists.
ADD ${JOOMLA_BACKUP_DATE}_cms-cbna-joomla_*.backup.tar.bz2 ${JOOMLA_PATH}/

RUN chown -R www-data: ${JOOMLA_PATH}

# Use new entry point wrapper
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
