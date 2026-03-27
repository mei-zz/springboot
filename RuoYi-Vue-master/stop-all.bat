@echo off
setlocal
chcp 65001 >nul

echo 正在停止前后端进程...
for /f "tokens=2" %%a in ('tasklist ^| findstr /i "java.exe"') do taskkill /f /pid %%a >nul 2>nul
for /f "tokens=2" %%a in ('tasklist ^| findstr /i "node.exe"') do taskkill /f /pid %%a >nul 2>nul
echo 已停止（如有未关闭窗口可手动关闭）。
exit /b 0
