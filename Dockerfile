FROM ghcr.io/cirruslabs/flutter:stable AS builder
WORKDIR /app
COPY . .
RUN flutter build web --release

FROM nginx:alpine AS runner
COPY --from=builder /app/build/web /usr/share/nginx/html/kanvas-embed
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
