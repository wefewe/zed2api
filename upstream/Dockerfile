# syntax=docker/dockerfile:1
FROM --platform=$BUILDPLATFORM node:20-alpine AS webui-build
WORKDIR /app/webui
COPY webui/package*.json ./
RUN npm ci
COPY webui/ ./
RUN npm run build

FROM --platform=$BUILDPLATFORM alpine:3.20 AS zig-build
ARG TARGETARCH
ARG BUILDARCH
WORKDIR /src

RUN apk add --no-cache curl tar xz

# 下载对应构建机平台的 Zig 0.15.2（原生运行，零 QEMU 仿真开销）
RUN case "${BUILDARCH:-amd64}" in \
        "amd64") ZIG_BUILD_ARCH="x86_64" ;; \
        "arm64") ZIG_BUILD_ARCH="aarch64" ;; \
        *) exit 1 ;; \
    esac && \
    curl -fsSL "https://ziglang.org/download/0.15.2/zig-${ZIG_BUILD_ARCH}-linux-0.15.2.tar.xz" -o /tmp/zig.tar.xz && \
    mkdir -p /opt/zig && \
    tar -xf /tmp/zig.tar.xz --strip-components=1 -C /opt/zig && \
    rm -f /tmp/zig.tar.xz

COPY . .
COPY --from=webui-build /app/webui/dist ./webui/dist

# 利用 Zig 原生交叉编译能力，15 秒直出目标架构静态二进制
RUN case "${TARGETARCH:-amd64}" in \
        "amd64") ZIG_TARGET="x86_64-linux-musl" ;; \
        "arm64") ZIG_TARGET="aarch64-linux-musl" ;; \
        *) exit 1 ;; \
    esac && \
    /opt/zig/zig build -Dtarget=${ZIG_TARGET} -Doptimize=ReleaseSafe

FROM alpine:3.20
RUN apk add --no-cache ca-certificates tzdata curl openssl \
 && mkdir -p /app/data
WORKDIR /app/data
COPY --from=zig-build /src/zig-out/bin/zed2api /usr/local/bin/zed2api

EXPOSE 8001
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s \
  CMD curl -fsS http://127.0.0.1:8001/v1/models || exit 1

ENTRYPOINT ["/usr/local/bin/zed2api", "serve", "8001"]
