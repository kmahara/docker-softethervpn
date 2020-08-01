FROM alpine:3 as builder
RUN apk add gcc make curl libc-dev zlib-dev readline-dev openssl-dev
RUN cd /tmp && \
	curl -sL https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.29-9680-rtm/softether-src-v4.29-9680-rtm.tar.gz | tar zxf -
RUN cd /tmp/v4.29-9680 && \
	./configure && \
	make -j2 install
RUN ls -lR /usr/vpnserver

FROM alpine:3
RUN apk --no-cache add readline iptables && \
	cd /usr && mkdir vpnserver vpnbridge vpnclient vpncmd 
COPY --from=builder /usr/bin/vpn* /usr/bin/
COPY --from=builder /usr/vpnserver/ /usr/vpnserver/
COPY --from=builder /usr/vpnbridge/ /usr/vpnbridge/
COPY --from=builder /usr/vpnclient/ /usr/vpnclient/
COPY --from=builder /usr/vpncmd/ /usr/vpncmd/
CMD ["/usr/vpnserver/vpnserver", "execsvc"]

