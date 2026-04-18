FROM gradle:8.5-jdk21 AS builder

WORKDIR /build
COPY . .
RUN gradle build -x test

FROM eclipse-temurin:21-jdk

WORKDIR /app
COPY --from=builder /build/service/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-jar", "app.jar"]