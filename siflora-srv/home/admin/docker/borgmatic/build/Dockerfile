FROM debian:11.7-slim AS builder
# Builder to avoid to embed develop files

LABEL mainainer="Jean-Pascal MILCENT"
LABEL source="https://github.com/b3vis/docker-borgmatic"

# Borg releases: https://www.borgbackup.org/releases/
ARG BORG_VERSION=1.2.4
# Borgmatic releases: see https://github.com/witten/borgmatic
ARG BORGMATIC_VERSION=1.7.14
# PyFuse releases: https://pypi.org/project/pyfuse3/#history
ARG PYFUSE_VERSION=3.2.3

# Install dev packages
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
		apt-utils \
    	python3 python3-dev python3-pip python3-virtualenv \
		libacl1-dev libacl1 \
        libssl-dev \
        liblz4-dev libzstd-dev libxxhash-dev \
        build-essential \
        pkg-config python3-pkgconfig \
        libfuse3-dev fuse3 \
	&& rm -rf /var/lib/apt/lists/* \
	&& python3 -m pip install --upgrade pip \
	&& python3 -m pip install -U pip setuptools wheel \
    && python3 -m pip install --upgrade borgbackup==${BORG_VERSION} \
    && python3 -m pip install --upgrade borgmatic==${BORGMATIC_VERSION} \
    && python3 -m pip install --upgrade pyfuse3==${PYFUSE_VERSION} \
	&& python3 -m pip install --upgrade ntfy[pid,emoji,xmpp,telegram,instapush,slack,rocketchat]


FROM debian:11.7-slim
LABEL mainainer="Jean-Pascal MILCENT"

ARG MAILTO
ARG PGSQL_MAJOR_VERSION

ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8
ENV TZ="Europe/Paris"

# Install utils and sendmail
# WARNING: use same postgresql-client package that the host server !
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --quiet --no-install-recommends \
            apt-utils locales less curl wget vim sudo cron iputils-ping gnupg lsb-release \
            msmtp msmtp-mta bsd-mailx mailutils \
            tzdata \
            sshfs \
            python3 \
            openssl \
            ca-certificates \
            fuse3 \
            lz4 \
            libacl1 \
    # Add postresql deb package repo
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - \ 
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
        apt-get install -y --quiet --no-install-recommends "postgresql-client-${PGSQL_MAJOR_VERSION}" \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Set the locale
RUN sed -i 's/# \(fr_FR\.UTF-8 .*\)/\1/' /etc/locale.gen \
    && touch /usr/share/locale/locale.alias \
	&& locale-gen

# Copy script to create msmtprc config file
# msmtprc.sh will be executed in docker-entrypoint.sh at runtime
COPY ./msmtprc.sh /etc/borgmatic.d/msmtprc.sh
RUN chmod 755 /etc/borgmatic.d/msmtprc.sh \
	&& touch /var/log/msmtp.log \
	&& chown root:msmtp /var/log/msmtp.log \
	&& chmod 664 /var/log/msmtp.log \
	&& ls -al /etc/borgmatic.d/

# Set Cron for borgmatic
# DON'T USE dot or dash in cron.d script file name howerer the script will never execute.
# DON'T add this cron file to crontab ! Crontab and /etc/cron.d are distinct ! Run two process !
COPY ./borgmatic.cron /etc/cron.d/borgmatic
RUN  chmod 0644 /etc/cron.d/borgmatic \
	&& chown root: /etc/cron.d/borgmatic \
	&& sed -i  "s/\${MAILTO}/${MAILTO}/" /etc/cron.d/borgmatic \
	&& chmod u+s /usr/sbin/cron \
	&& touch /var/log/cron.log

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
	&& echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
	&& echo "set mouse=" >> /etc/vim/vimrc.local

# Uncomment alias from /root/.bashrc
RUN sed -i 's/^# alias/alias/' /root/.bashrc

# Add Telegram send message script
COPY ./telegram-send.sh /usr/local/bin/telegram-send
RUN  chmod 0755 /usr/local/bin/telegram-send

# Copy file from "builder" image
#COPY --from=builder /usr/lib/python3/dist-packages /usr/lib/python3/
COPY --from=builder /usr/local/lib/python3.9/dist-packages /usr/local/lib/python3.9/dist-packages
COPY --from=builder /usr/local/bin/borg /usr/local/bin/
COPY --from=builder /usr/local/bin/borgfs /usr/local/bin/
COPY --from=builder /usr/local/bin/borgmatic /usr/local/bin/
COPY --from=builder /usr/local/bin/generate-borgmatic-config /usr/local/bin/
COPY --from=builder /usr/local/bin/upgrade-borgmatic-config /usr/local/bin/
COPY --from=builder /usr/local/bin/validate-borgmatic-config /usr/local/bin/
COPY --from=builder /usr/local/bin/ntfy /usr/local/bin/

RUN chmod 744 /usr/local/bin/borgmatic

# Prepare entry point script
COPY ./docker-entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

CMD ["/entrypoint.sh"]

