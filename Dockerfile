FROM instrumentisto/flutter:latest AS build


WORKDIR /app
COPY pubspec.* ./

RUN flutter pub get


COPY . .

RUN flutter build web

FROM nginx:1.25.3 AS prod

EXPOSE 80

COPY --from=build /app/build/web /usr/share/nginx/html
