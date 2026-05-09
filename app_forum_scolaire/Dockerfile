# Stage 1: Build Flutter Web and APK
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root
WORKDIR /app

# Copy project files
COPY . .

# Accept Android licenses
RUN yes | flutter doctor --android-licenses

# Fix git dubious ownership when running as root, and enable web
RUN git config --global --add safe.directory /app && flutter config --enable-web

# Get dependencies
RUN flutter pub get

# Build Web
RUN flutter build web --release -v


# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy web artifacts to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html


# Add a script to inject environment variables into the .env file at runtime
RUN echo '#!/bin/sh' > /entrypoint.sh && \
    echo 'if [ -n "$API_BASE_URL" ]; then sed -i "s|API_BASE_URL=.*|API_BASE_URL=$API_BASE_URL|g" /usr/share/nginx/html/assets/.env.local; fi' >> /entrypoint.sh && \
    echo 'if [ -n "$APP_DEMO" ]; then sed -i "s|APP_DEMO=.*|APP_DEMO=$APP_DEMO|g" /usr/share/nginx/html/assets/.env.local; fi' >> /entrypoint.sh && \
    echo 'exec nginx -g "daemon off;"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Expose port 80
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
