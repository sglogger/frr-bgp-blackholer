FROM alpine
LABEL maintainer="Steven Glogger <steven@glogger.ch>"

RUN apk update && apk add --no-cache \
	busybox-extras \
	bash \
	tini

# Configuration files
VOLUME /data

# Command
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/sbin/crond", "-f"]

