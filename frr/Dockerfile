FROM frrouting/frr
LABEL maintainer="Steven Glogger <steven@glogger.ch>"

RUN apk update && apk add --no-cache \
	busybox-extras \
	supervisor

# Configuration files
VOLUME /etc/frr
RUN mkfifo -m 0666 /var/log/frrlog.pipe && chown frr:frr /var/log/frrlog.pipe
RUN sed -i 's:tail -f /dev/null:cat /var/log/frrlog.pipe:g' /usr/lib/frr/docker-start
ADD update-routing.sh /etc/periodic/hourly/update-routing
ADD entrypoint.sh /

# Command
#ENTRYPOINT [ "/sbin/tini", "--", "/usr/lib/frr/docker-start" ]
ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]
#debug > ENTRYPOINT [ "sleep","999999" ]
