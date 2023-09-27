FROM debian:12.1-slim
# https://hub.docker.com/_/debian

LABEL maintainer "Jean-Pascal MILCENT <jpm@clapas.org>"

ARG TZ=${TZ:-Europe/Paris}
ARG MARIADB_REPO_SETUP_CHECKSUM
ARG HOST_USER_NAME
ARG HOST_USER_ID
ARG HOST_GROUP_ID

ENV DEFAULT_TZ ${TZ}
ENV HOST_USER_ID ${HOST_USER_ID}
ENV HOST_GROUP_ID ${HOST_GROUP_ID}

# Add an user like the host running the container
RUN if [ ${HOST_USER_ID:-0} -ne 0 ] && [ ${HOST_GROUP_ID:-0} -ne 0 ]; then \
		groupadd -g ${HOST_GROUP_ID} ${HOST_USER_NAME} && \
		useradd -l -u ${HOST_USER_ID} -g ${HOST_USER_NAME} ${HOST_USER_NAME} ; \
	fi

# Install system packages
RUN apt-get update && \
	apt-get -y upgrade && \
	apt-get -y install \
		wget \
		curl \
		apt-transport-https \
		apt-utils \
		cron \
		bzip2 \
		vim && \
	apt-get clean autoclean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/{apt,dpkg,cache,log}

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
	&& echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
	&& echo "set mouse=" >> /etc/vim/vimrc.local

# Uncomment alias from /root/.bashrc
RUN sed -i -r 's/^# (alias|export|eval)/\1/' /root/.bashrc

# Install mariadb-client
RUN wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup && \
    echo "${MARIADB_REPO_SETUP_CHECKSUM}  mariadb_repo_setup" \
        | sha256sum -c - && \
	chmod +x ./mariadb_repo_setup && \
	./mariadb_repo_setup && \
	apt-get install -y mariadb-client && \
	apt-get clean autoclean && \
	apt-get -y autoremove && \
	rm -rf /var/lib/{apt,dpkg,cache,log}

# Copy script for backup
COPY ./backup.sh /usr/local/sbin/backup.sh
RUN chmod 755 /usr/local/sbin/backup.sh

# Copy and active Cron
COPY ./backup.cron /etc/cron.d/backup
RUN chmod 0644 /etc/cron.d/backup && \
    chown root: /etc/cron.d/backup && \
    chmod u+s /usr/sbin/cron && \
	touch /var/log/cron.log

# Use new entry point wrapper
COPY ./backup-entrypoint.sh /backup-entrypoint.sh
RUN chmod 755 /backup-entrypoint.sh
ENTRYPOINT ["/backup-entrypoint.sh"]
