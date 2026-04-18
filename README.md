# Gateway Service

`gateway-service` — единая точка входа в микросервисную архитектуру Rent Platform. Он принимает запросы от фронтенда, маршрутизирует их в нужные микросервисы и выполняет проверку JWT для защищённых endpoint'ов.

## Основной функционал

- маршрутизация HTTP-запросов в downstream-сервисы
- централизованная проверка access JWT
- разграничение открытых и защищённых endpoint'ов
- CORS-конфигурация для фронтенда и Swagger
- единая точка входа для клиентских приложений

## Технологии

- Java 21
- Spring Boot 4
- Spring Cloud Gateway Server MVC
- Spring Security
- OAuth2 Resource Server
- Nimbus JWT Decoder
- Actuator
- Docker
- Docker Compose

## Назначение в системе

Фронтенд должен обращаться только в `gateway-service`, а не напрямую в отдельные микросервисы.

Типовая схема работы:

`Frontend -> Gateway -> User Service`

Это упрощает клиентскую интеграцию и делает архитектуру более централизованной.

## Безопасность

`gateway-service` не выпускает токены. Он:

- принимает access JWT от клиента
- валидирует подпись по публичному RSA-ключу
- пропускает только валидные запросы к защищённым endpoint'ам

### Открытые endpoint'ы

Обычно без JWT доступны:

- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/users/test`
- Swagger endpoints
- Actuator endpoints

### Защищённые endpoint'ы

JWT обязателен для:

- `GET /api/users/me`
- `PUT /api/users/me`
- `PUT /api/users/me/password`
- `DELETE /api/users/me`
- других защищённых endpoint'ов downstream-сервисов

## JWT

Для проверки токенов используется публичный RSA-ключ:

- `public.pem`

Gateway использует только публичный ключ. Приватный ключ хранится в `user-service`, где и происходит выпуск access token.

## Маршрутизация

На текущем этапе в gateway настроены маршруты для `user-service`.

### Локальный запуск

В локальном профиле маршруты направляются на:

- `http://localhost:8081`

### Docker-запуск

В docker-профиле маршруты направляются на:

- `http://user-service:8081`

Это позволяет корректно работать как локально, так и внутри docker-сети.

## Примеры маршрутов

### User Service

- `/api/auth/**` -> `user-service`
- `/api/users/**` -> `user-service`

### Будущие маршруты

В проекте также предусмотрены заготовки под другие микросервисы:

- `catalog-service`
- `deal-service`
- `comm-service`
- `notif-service`

На текущем этапе они могут быть описаны в локальном конфиге как будущие маршруты, но основной рабочий сценарий сосредоточен на `user-service`.

## CORS

В `gateway-service` настроен CORS для работы:

- фронтенда
- Swagger UI
- локальной разработки
- docker-окружения

Разрешаются origin'ы, например:

- `http://localhost:3000`
- `http://localhost:5173`
- `http://localhost:8081`
- `http://localhost:8181`

Также разрешены preflight `OPTIONS` запросы.

## Конфигурация

### Профили запуска

#### Локальный профиль
Используется `application.yaml`.

Обычно:
- gateway доступен на `8080`
- user-service доступен на `8081`

#### Docker-профиль
Используется `application-docker.yaml`.

Обычно:
- gateway проброшен на `8180`
- user-service проброшен на `8181`

## Actuator

Actuator используется для базового мониторинга.

Открыты endpoint'ы:

- `health`
- `info`

## Docker

`gateway-service` используется как точка запуска docker-compose для текущего MVP.

Через `docker-compose` поднимаются:

- PostgreSQL
- `user-service`
- `gateway-service`

Это позволяет фронтенду и разработчику запускать всю базовую инфраструктуру одной командой.

## Пример docker-compose сценария

Через compose поднимаются:

- БД PostgreSQL
- контейнер `user-service`
- контейнер `gateway-service`

Хост-порты для Docker-режима:

- `8180` -> gateway
- `8181` -> user-service
- `5433` -> PostgreSQL

## Swagger и тестирование

Swagger обычно открывается через `user-service`, но запросы можно направлять через gateway, выбрав соответствующий server в OpenAPI-конфигурации.

### Примеры URL

Локально:
- `http://localhost:8080`

В Docker:
- `http://localhost:8180`

## Как запускать

### Локально
1. Запустить `user-service`
2. Запустить `gateway-service`
3. Отправлять запросы через `http://localhost:8080`

### Через Docker
1. Перейти в репозиторий `gateway-service`
2. Выполнить:

```bash
docker-compose up --build
```

После запуска доступны:

- gateway: `http://localhost:8180`
- user-service: `http://localhost:8181`
