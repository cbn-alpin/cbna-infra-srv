ARG TAIGA_VERSION="${TAIGA_VERSION:-6.7.0}"
ARG TCOA_RELEASE="${TCOA_RELEASE:-master}"

FROM taigaio/taiga-back:${TAIGA_VERSION}

ENV OPENID_SCOPE="openid email"
ENV TCOA_URL="https://github.com/robrotheram/taiga-contrib-openid-auth/archive/refs/heads/${TCOA_RELEASE}.tar.gz"

ADD config.snippet.py /tmp

RUN python -c "import urllib.request as r; r.urlretrieve(\"${TCOA_URL}\", \"/tmp/taiga-contrib-openid-auth.tar.gz\")" \
	&& tar xzf /tmp/taiga-contrib-openid-auth.tar.gz -C /tmp \
	&& pip install /tmp/taiga-contrib-openid-auth*/back \
	&& rm -r /tmp/taiga-contrib-openid-auth* \
	&& cat /tmp/config.snippet.py >> /taiga-back/settings/config.py
