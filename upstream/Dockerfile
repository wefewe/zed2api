# syntax=docker/dockerfile:1
FROM node:20-alpine AS webui-build
WORKDIR /app/webui
COPY webui/package*.json ./
RUN npm ci
COPY webui/ ./
RUN npm run build

FROM alpine:3.20 AS zig-build
ARG TARGETARCH
WORKDIR /src

RUN apk add --no-cache curl tar xz

# 下载对应架构的 Zig 0.15.2
RUN case "${TARGETARCH:-arm64}" in \
        "amd64") ZIG_ARCH="x86_64" ;; \
        "arm64") ZIG_ARCH="aarch64" ;; \
        *) echo "Unsupported arch: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    curl -fsSL "https://ziglang.org/download/0.15.2/zig-${ZIG_ARCH}-linux-0.15.2.tar.xz" -o /tmp/zig.tar.xz && \
    mkdir -p /opt/zig && \
    tar -xf /tmp/zig.tar.xz --strip-components=1 -C /opt/zig && \
    rm -f /tmp/zig.tar.xz

COPY . .
COPY --from=webui-build /app/webui/dist ./webui/dist

RUN /opt/zig/zig build -Doptimize=ReleaseSafe

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata curl openssl \
 && mkdir -p /app/data
WORKDIR /app/data
COPY --from=zig-build /src/zig-out/bin/zed2api /usr/local/bin/zed2api

EXPOSE 8001
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD curl -fsS http://127.0.0.1:8001/v1/models || exit 1

ENTRYPOINT ["/usr/local/bin/zed2api", "serve", "8001"]
