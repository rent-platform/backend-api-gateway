@echo off
setlocal

echo ==========================================
echo Building user-service...
echo ==========================================
cd /d ..\backend-user-service
call gradlew.bat build -x test
if errorlevel 1 goto :error

echo ==========================================
echo Building catalog-service...
echo ==========================================
cd /d ..\backend-catalog-service
call gradlew.bat build -x test
if errorlevel 1 goto :error

echo ==========================================
echo Building gateway-service...
echo ==========================================
cd /d ..\gateway-service
call gradlew.bat build -x test
if errorlevel 1 goto :error

echo ==========================================
echo Starting docker compose...
echo ==========================================
docker compose up --build -d
if errorlevel 1 goto :error

echo.
echo ==========================================
echo Services started successfully
echo ==========================================
echo Gateway:                 http://localhost:8180
echo User Service Swagger:    http://localhost:8181/swagger-ui/index.html
echo Catalog Service Swagger: http://localhost:8182/swagger-ui/index.html
echo Postgres:                localhost:5433
echo.
echo Useful endpoints:
echo User API via Gateway:    http://localhost:8180/api/auth/login
echo Catalog API via Gateway: http://localhost:8180/api/catalog/items
echo.
echo To stop all services:
echo docker compose down
echo ==========================================
goto :eof

:error
echo.
echo ==========================================
echo Build or startup failed
echo ==========================================
exit /b 1