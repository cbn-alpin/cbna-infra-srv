ARG TAIGA_VERSION="${TAIGA_VERSION:-latest}"
ARG TCOA_RELEASE="${TCOA_RELEASE:-master}"

FROM taigaio/taiga-front:${TAIGA_VERSION}

ENV OPENID_SCOPE="openid email"
ENV TCOA_URL="https://github.com/robrotheram/taiga-contrib-openid-auth/archive/refs/heads/${TCOA_RELEASE}.tar.gz"

COPY conf.template.json /usr/share/nginx/html/conf.template.json
COPY 30_config_env_subst.sh /docker-entrypoint.d/30_config_env_subst.sh

RUN wget -O /tmp/taiga-contrib-openid-auth.tar.gz "${TCOA_URL}" \
	&& tar xzf /tmp/taiga-contrib-openid-auth.tar.gz -C /tmp \
	&& mkdir -p /usr/share/nginx/html/plugins/openid-auth \
	&& cp -r /tmp/taiga-contrib-openid-auth*/front/dist/* /usr/share/nginx/html/plugins/openid-auth
