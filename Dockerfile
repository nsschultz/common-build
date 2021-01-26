FROM mcr.microsoft.com/dotnet/sdk:5.0 AS base-csharp-builder
RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2
RUN apt-get update && apt-get install -y --no-install-recommends openjdk-11-jre && \
    dotnet tool install --global dotnet-sonarscanner --version 4.9.0 && \
    dotnet tool install --global MiniCover --version 3.1.0
ENV DOTNET_ROLL_FORWARD=Major \
    PATH="$PATH:/root/.dotnet/tools"
WORKDIR /app
COPY build.sh .
RUN chmod +x ./build.sh

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base-csharp-runner
RUN useradd -u 5000 service-user && mkdir /app && chown -R service-user:service-user /app
ENV ASPNETCORE_URLS=http://+:8080
USER service-user:service-user
WORKDIR /app

FROM nginx:1.18.0 AS base-nginx-runner
RUN useradd -u 5000 ng-user && \
    mkdir -p /var/run/nginx /var/tmp/nginx && \
    chown -R ng-user:ng-user /usr/share/nginx /var/run/nginx /var/tmp/nginx
USER ng-user:ng-user
CMD ["nginx", "-g", "daemon off;"]