# syntax=docker/dockerfile:1
# Build (vendored modules, tests run as part of the image build)
FROM golang:1.27.2-alpine AS build

ARG TAG

WORKDIR /src
COPY . .
RUN CGO_ENABLED=0 go build -mod=vendor -trimpath -ldflags "-s -w" -o /out/app ./cmd
RUN CGO_ENABLED=0 go test -mod=vendor ./...

# Runtime
FROM alpine:3.24.2

# Pull distro security fixes newer than the tagged base.
RUN apk upgrade --no-cache

COPY --from=build /out/app /app/app

# Non-root, numeric so runAsNonRoot can be enforced by the pod securityContext.
# Same uid/gid as the upstream distroless nonroot image (65532).
USER 65532:65532

EXPOSE 8080/tcp

ENTRYPOINT ["/app/app"]
