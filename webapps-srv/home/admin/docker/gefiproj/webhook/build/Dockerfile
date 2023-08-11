FROM almir/webhook:2.8.1 AS source


FROM alpine:3.18.3

COPY --from=source /usr/local/bin/webhook /usr/local/bin/webhook

RUN  apk --update --upgrade add docker curl bash && \
	rm -rf /var/cache/apk/*

WORKDIR     /etc/webhook
VOLUME      ["/etc/webhook"]
EXPOSE      9000
ENTRYPOINT  ["/usr/local/bin/webhook"]
