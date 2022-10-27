FROM golang:alpine AS xray
RUN apk update && apk add --no-cache git
WORKDIR /go/src/xray/core
RUN git clone --progress https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main 
	
FROM golang:alpine AS caddy	
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest && \
    xcaddy build latest
	
FROM alpine:edge
COPY --from=xray /tmp/xray /usr/bin 
COPY --from=caddy /usr/bin/caddy /usr/bin
COPY entrypoint.sh /usr/bin

RUN set -xe \
    && apk update \
    && apk add --no-cache ca-certificates tor wget \
    && mkdir -p /etc/xray /etc/caddy /usr/share/caddy \
    && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt \
    && wget https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html -O /usr/share/caddy/index.html \
    && chmod +x /usr/bin/xray \
    && chmod +x /usr/bin/caddy \
    && chmod +x /usr/bin/entrypoint.sh \
    && rm -rf /var/cache/apk/*
	
COPY Caddyfile /etc/caddy/Caddyfile
COPY config.json /etc/caddy/config.json 

CMD ["/usr/bin/entrypoint.sh"]
