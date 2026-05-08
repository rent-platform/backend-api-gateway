# Gateway Service

`gateway-service` — единая точка входа в микросервисную архитектуру Rent Platform. Принимает запросы от фронтенда, 
маршрутизирует их в нужные микросервисы и выполняет централизованную проверку JWT.

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
---

## Порты

| Service      | Port |
|-------------|------|
| Gateway     | 8080 |
| User        | 8081 |
| Catalog     | 8082 |
| Deal-Payment | 8083 |
| Communication | 8084 |

---

## Маршрутизация

| Маршрут                  | Сервис              |
|--------------------------|---------------------|
| `/api/auth/**`           | user-service        |
| `/api/users/**`          | user-service        |
| `/api/admin/**`          | user-service        |
| `/api/catalog/**`        | catalog-service     |
| `/api/catalog/admin/**`  | catalog-service     |
| `/api/deals/**`          | deal-payment-service |
| `/api/reviews/**`        | deal-payment-service |
| `/api/complaints/**`     | deal-payment-service |
| `/api/webhooks/**`       | deal-payment-service |
| `/api/chats/**`          | communication-service |
| `/api/internal/chats/**` | communication-service |

---


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
- `GET /api/users/*/public`
- `GET /api/catalog/categories/**`
- `GET /api/catalog/items/**`
- `GET /api/reviews/users/*`
- `GET /api/reviews/items/*`
- `GET /api/reviews/users/*/summary`
- `GET /api/reviews/items/*/summary`
- `POST /api/webhooks/**`
- `GET /ws/**` (WebSocket)
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

---

## CORS

Разрешённые origin'ы:

- `http://localhost:3000`
- `http://localhost:5173`
- `http://localhost:8080` – `http://localhost:8085`
- `http://localhost:8180` – `http://localhost:8185`

Методы: `GET`, `POST`, `PUT`, `DELETE`, `OPTIONS`, `PATCH`

Заголовки: все (`*`)

Preflight `OPTIONS` запросы разрешены для всех маршрутов.

---

## Конфигурация

### Локальный профиль (`application.yml`)

- server.port: 8080
- Маршруты → localhost:8081–8084

### Docker-профиль (`application-docker.yml`)

- server.port: 8180
#### Маршруты 
- user-service:8181, 
- catalog-service:8182, 
- deal-payment-service:8183, 
- communication-service:8184

---

## Actuator

Открыты endpoint'ы: `health`, `info`

---

## Swagger и тестирование

Swagger доступен через gateway для каждого сервиса. Выбрать нужный сервер в OpenAPI-конфигурации.

### URL'ы

Локально:
- Gateway: `http://localhost:8080`
- Swagger: `http://localhost:8080/swagger-ui.html`

## Docker

`gateway-service` используется как точка запуска docker-compose для текущего MVP.

Через `docker-compose` поднимаются:

- PostgreSQL
- `user-service`
- `gateway-service`
- `catalog-service`
- `deal-payment-service`
- `communication-service`

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

## Как запускать

### Локально
1. Запустить `user-service`
2. Запустить `gateway-service`
3. Отправлять запросы через `http://localhost:8080`

### Через Docker
1. Перейти в репозиторий `gateway-service`
2. Выполнить:

```bash
# Запустить все сервисы
./gradlew bootRun

docker-compose up --build
```

После запуска доступны:

- Gateway: http://localhost:8180
- User Service: http://localhost:8181
- Catalog Service: http://localhost:8182
- Deal-Payment Service: http://localhost:8183
- Communication Service: http://localhost:8184
