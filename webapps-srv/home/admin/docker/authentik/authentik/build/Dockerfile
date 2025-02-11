FROM ghcr.io/goauthentik/server:2024.10.0

LABEL maintainer="Jean-Pascal MILCENT"


ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8
ENV VENV_PATH="/ak-root/venv"

USER root

# Install packages
RUN apt-get update \
        && DEBIAN_FRONTEND=noninteractive \
                apt-get install -y --quiet --no-install-recommends \
                        apt-utils locales less curl wget vim bash-completion \
        && apt-get -y autoremove \
        && apt-get clean autoclean \
        && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/*

# Add forgotten Python modules
RUN bash -c "source ${VENV_PATH}/bin/activate && \
    pip3 install daphne"

# Add /etc/vim/vimrc.local
RUN echo "runtime! defaults.vim" > /etc/vim/vimrc.local \
        && echo "let g:skip_defaults_vim = 1" >> /etc/vim/vimrc.local  \
        && echo "set mouse=" >> /etc/vim/vimrc.local


# Uncomment alias from /root/.bashrc
RUN sed -i 's/^# alias/alias/' /root/.bashrc
RUN echo ' \n\
if ! shopt -oq posix; then\n\
  if [ -f /usr/share/bash-completion/bash_completion ]; then\n\
    . /usr/share/bash-completion/bash_completion\n\
  elif [ -f /etc/bash_completion ]; then\n\
    . /etc/bash_completion\n\
  fi\n\
fi' >> /root/.bashrc

USER 1000
