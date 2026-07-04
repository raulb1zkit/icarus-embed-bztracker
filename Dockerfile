# Pin the image used by the last deployment so future stable releases cannot
# silently change the compiler underneath a previously reproducible build.
FROM ghcr.io/cirruslabs/flutter:stable@sha256:46691e311715845de03a3ba4753a475476936805b29431b1f00f1816981033f8 AS builder
WORKDIR /app
COPY . .
RUN flutter build web --release --no-tree-shake-icons --base-href /kanvas-embed/

FROM nginx:alpine AS runner
COPY --from=builder /app/build/web /usr/share/nginx/html/kanvas-embed
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
