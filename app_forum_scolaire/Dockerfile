# Stage 1: Build Flutter Web and APK
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

USER root
WORKDIR /app

# Copy project files
COPY . .

# Accept Android licenses
RUN yes | flutter doctor --android-licenses

# Get dependencies
RUN flutter pub get

# Build Web
RUN flutter build web --release

# Build APK
RUN flutter build apk --release

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy web artifacts to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy the generated APK into the assets folder of the web server
# This allows users to download the APK directly from the website
RUN mkdir -p /usr/share/nginx/html/assets
COPY --from=build-env /app/build/app/outputs/flutter-apk/app-release.apk /usr/share/nginx/html/assets/app-release.apk

# Expose port 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
