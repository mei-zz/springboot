@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set ROOT=%~dp0
cd /d "%ROOT%"

echo [1/6] 检查运行环境...
where java >nul 2>nul
if errorlevel 1 (
  echo [错误] 未找到 Java，请先安装并配置 PATH。
  exit /b 1
)
where npm >nul 2>nul
if errorlevel 1 (
  echo [错误] 未找到 npm，请先安装 Node.js 并配置 PATH。
  exit /b 1
)

set MVN_CMD=mvn
if exist "D:\apache-maven-3.9.6\bin\mvn.cmd" set MVN_CMD=D:\apache-maven-3.9.6\bin\mvn.cmd

set NEED_BUILD=0
if /i "%~1"=="--build" set NEED_BUILD=1
if not exist "%ROOT%ruoyi-admin\target\ruoyi-admin.jar" set NEED_BUILD=1

if "%NEED_BUILD%"=="1" (
  echo [2/6] 打包后端（ruoyi-admin）...
  call "%MVN_CMD%" -q -pl ruoyi-admin -am -DskipTests package
  if errorlevel 1 (
    echo [错误] 后端打包失败，请检查 Maven 输出。
    exit /b 1
  )
) else (
  echo [2/6] 检测到现有后端 JAR，跳过打包（如需强制打包请执行 start-all.bat --build）...
)

if not exist "%ROOT%ruoyi-admin\target\ruoyi-admin.jar" (
  echo [错误] 未找到后端 JAR：ruoyi-admin\target\ruoyi-admin.jar
  exit /b 1
)

echo [3/6] 启动后端...
start "ruoyi-backend" cmd /k "cd /d "%ROOT%ruoyi-admin\target" && java -jar ruoyi-admin.jar"

echo [4/6] 安装前端依赖（首次会较慢）...
if not exist "%ROOT%ruoyi-ui\node_modules" (
  cd /d "%ROOT%ruoyi-ui"
  call npm install
  if errorlevel 1 (
    echo [错误] 前端依赖安装失败。
    exit /b 1
  )
  cd /d "%ROOT%"
)

echo [5/6] 启动前端...
start "ruoyi-frontend" cmd /k "cd /d "%ROOT%ruoyi-ui" && npm run dev"

echo [6/6] 等待服务启动并执行功能自检...
timeout /t 25 /nobreak >nul
call "%ROOT%check-features.bat"

echo.
echo 已执行完成。正在打开浏览器...
start http://localhost
echo 访问地址：
echo frontend: http://localhost
echo backend:  http://localhost:8080
echo.
echo 如需关闭服务，请执行 stop-all.bat
exit /b 0
