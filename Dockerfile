FROM golang:1.24-alpine3.22 AS builder
ENV GO111MODULE=on GOPROXY=https://goproxy.cn,direct
WORKDIR /app
COPY . /app
RUN go mod init github.com/mhausenblas/yages && \
    go mod tidy && \
    go build -ldflags "-X main.release=0.1.0" -o ./srv-yages ./main.go

FROM alpine:3.22
LABEL version=0.1.0 \
      description="YAGES gRPC server" \
      maintainer="michael.hausenblas@gmail.com"
WORKDIR /app
RUN sed -i 's#dl-cdn.alpinelinux.org#mirror.tuna.tsinghua.edu.cn#g' /etc/apk/repositories && \
    apk update && apk add --no-cache tzdata bash tini bind-tools net-tools vim curl && \
    rm -rf /var/cache/apk/* && \
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai">/etc/timezone
COPY --from=builder /app/srv-yages /app/srv-yages
EXPOSE 9000
ENTRYPOINT ["/sbin/tini", "--", "/app/srv-yages"]
