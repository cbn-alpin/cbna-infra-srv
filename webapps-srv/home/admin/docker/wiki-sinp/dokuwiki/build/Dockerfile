FROM php:8.1.22-fpm-bookworm

LABEL author="Jean-Pascal MILCENT" \
  version="1.3" \
  maintainer="jp.milcent@cbn-alpin.fr"

ARG BACKUP_DATE
ARG MSMTP_OVH_PWD

ENV DW_VERSION=2023-04-04a
ENV DW_DOWNLOAD_URL=https://download.dokuwiki.org/src/dokuwiki/dokuwiki-${DW_VERSION}.tgz
# On local machine, download file and get md5 with : md5sum dokuwiki-${DW_VERSION}.tgz
ENV DW_MD5_CHECKSUM=8a68393e689bf6d1130bfe660a19fc6b
ENV HTML_PATH /var/www/html

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
        vim \
		wget \
		bzip2 \
		libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
		msmtp msmtp-mta bsd-mailx mailutils && \
    docker-php-ext-install -j$(nproc) iconv && \
    docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
	apt-get clean autoclean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/{apt,dpkg,cache,log}

# Use the default production configuration
RUN mv "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini"
# Override php.ini properties for Dokuwiki
COPY dokuwiki.ini /usr/local/etc/php/conf.d/dokuwiki.ini

# Create Msmtp config file
COPY msmtprc.conf /etc/msmtprc
RUN sed -i "s/\$MSMTP_OVH_PWD/${MSMTP_OVH_PWD}/g" /etc/msmtprc && \
	chmod 600 /etc/msmtprc && \
	chown www-data:www-data /etc/msmtprc && \
	touch /var/log/msmtp.log && \
	chown www-data:www-data /var/log/msmtp.log

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
	&& echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
	&& echo "set mouse=" >> /etc/vim/vimrc.local

# Uncomment alias from /root/.bashrc
RUN sed -i 's/^# alias/alias/' /root/.bashrc

# Install or update Dokuwiki
WORKDIR /tmp
SHELL ["/bin/bash", "-c"]
RUN wget -q -O dokuwiki.tgz ${DW_DOWNLOAD_URL}
RUN if [ "${DW_MD5_CHECKSUM}" != "$(md5sum dokuwiki.tgz | awk '{print($1)}')" ];then \
      echo "Dokuwiki downloaded file have wrong md5sum !"; \
      exit 1; \
    fi
#RUN tar xzf dokuwiki.tgz -C /var/www/html --strip-components 1
RUN tar zxvf dokuwiki.tgz
RUN ls -al
RUN rm -f dokuwiki.tgz

RUN 'cp' -af dokuwiki-${DW_VERSION}/* ${HTML_PATH}/
#RUN rm -fR dokuwiki-${DW_VERSION}/
ADD ./${BACKUP_DATE}_wiki-sinp_backup.tar.bz2 ${HTML_PATH}
RUN chown -R www-data: ${HTML_PATH}

# Copy entrypoint script. Entypoint script upgade Dokuwiki files in named Volume
COPY dokuwiki-entrypoint.sh /usr/local/bin/
RUN sed -i "s#\${DW_VERSION}#${DW_VERSION}#g" /usr/local/bin/dokuwiki-entrypoint.sh && \
	sed -i "s#\${HTML_PATH}#${HTML_PATH}#g" /usr/local/bin/dokuwiki-entrypoint.sh
ENTRYPOINT ["/usr/local/bin/dokuwiki-entrypoint.sh", "docker-php-entrypoint"]
CMD ["php-fpm"]

WORKDIR ${HTML_PATH}
