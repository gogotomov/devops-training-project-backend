FROM gradle:4.7.0-jdk8-alpine as build

WORKDIR /home/gradle
USER root
COPY --chown=gradle:gradle . /home/gradle
RUN mkdir /home/gradle/files
RUN gradle build --no-daemon -x test
RUN mv build/resources/main/application.properties ./files 
RUN mv build/libs/gradle.jar /home/gradle/files/backend.jar

FROM openjdk:8-jre-slim
WORKDIR /opt/backend
RUN groupadd -r spring && useradd -r -g spring spring
USER spring
COPY --from=build --chown=spring:spring /home/gradle/files/* ./
ENTRYPOINT [ "java", "-jar", "/opt/backend/backend.jar", "--spring.config.location=file:/opt/backend/" ]

ARG DEFAULT_DB_URL
ENV DB_URL=${DEFAULT_DB_URL:-"localhost"}
ARG DEFAULT_DB_PORT
ENV DB_PORT=${DEFAULT_DB_PORT:-"3306"}
ARG DEFAULT_DB_USERNAME
ENV DB_USERNAME=${DEFAULT_DB_USERNAME:-"conduit"}
ARG DEFAULT_DB_PASSWORD
ENV DB_PASSWORD=${DEFAULT_DB_PASSWORD:-"conduit"}
ARG DEFAULT_DB_NAME
ENV DB_NAME=${DEFAULT_DB_NAME:-"CONDUIT"}

EXPOSE 8080
