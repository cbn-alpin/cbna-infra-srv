FROM almir/webhook:2.8.1 AS source


FROM alpine:3.18.3

ARG TZ=${TZ:-Europe/Paris}

ENV DEFAULT_TZ ${TZ}

COPY --from=source /usr/local/bin/webhook /usr/local/bin/webhook
COPY ./bashrc.sh /root/.bashrc

RUN  apk --update --upgrade add docker docker-compose curl bash tzdata && \
	cp /usr/share/zoneinfo/${DEFAULT_TZ} /etc/localtime && \
	apk del tzdata && \
	rm -rf /var/cache/apk/*

WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
