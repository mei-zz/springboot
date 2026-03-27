@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set ROOT=%~dp0
cd /d "%ROOT%"
set MYSQL_PWD=mei123456

set PASS_COUNT=0
set TOTAL_COUNT=0

echo ================== 功能自检开始 ==================

call :check_http "后端根路径" "http://localhost:8080" "200 401"
call :check_http "前端首页" "http://localhost" "200"
call :check_http "社交匹配接口" "http://localhost:8080/biz/social/match/1" "200 401"
call :check_http "健康记录接口" "http://localhost:8080/biz/health/list" "200 401"
call :check_http "健康预警接口" "http://localhost:8080/biz/alert/list" "200 401"
call :check_http "内容列表接口" "http://localhost:8080/biz/content/list" "200 401"
call :check_http "活动列表接口" "http://localhost:8080/biz/activity/list" "200 401"
call :check_http "审核内容列表接口" "http://localhost:8080/biz/audit/content/list" "200 401"

call :check_mysql_table biz_pet_info
call :check_mysql_table biz_health_record
call :check_mysql_table biz_health_alert
call :check_mysql_table biz_social_match
call :check_mysql_table biz_content_post
call :check_mysql_table biz_community_activity
call :check_mysql_table biz_activity_signup

echo --------------------------------------------------
echo 自检结果：!PASS_COUNT!/!TOTAL_COUNT! 项通过
if "!PASS_COUNT!"=="!TOTAL_COUNT!" (
  echo [通过] 核心功能已就绪，可直接访问页面进行操作。
) else (
  echo [警告] 存在未通过项，请查看上方输出并修复。
)
echo ================== 功能自检结束 ==================
exit /b 0

:check_http
set /a TOTAL_COUNT+=1
set NAME=%~1
set URL=%~2
set ALLOW=%~3
set CODE=
set TRY=0
:retry_http
set /a TRY+=1
for /f %%i in ('curl -s -o nul -w "%%{http_code}" "%URL%"') do set CODE=%%i
if "!CODE!"=="000" if !TRY! lss 6 (
  timeout /t 2 /nobreak >nul
  goto :retry_http
)

echo [HTTP] %NAME% - %URL% - 状态码: !CODE!
echo !ALLOW! | findstr /r /c:"\<!CODE!\>" >nul
if not errorlevel 1 (
  set /a PASS_COUNT+=1
  echo   ^> 通过
) else (
  echo   ^> 失败（期望: %ALLOW%）
)
goto :eof

:check_mysql_table
set /a TOTAL_COUNT+=1
set TB=%~1
set FOUND=
for /f %%i in ('echo show tables; ^| mysql -u root -D ry-vue -N 2^>nul') do (
  if /i "%%i"=="%TB%" set FOUND=%%i
)
if /i "!FOUND!"=="%TB%" (
  set /a PASS_COUNT+=1
  echo [DB] 表 %TB% 存在 - 通过
) else (
  echo [DB] 表 %TB% 不存在或数据库不可连接 - 失败
)
goto :eof
