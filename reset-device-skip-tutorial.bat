@echo off
chcp 65001 >nul
title Typeless 设备标识重置工具 - 跳过新手引导版 (Windows 11 / 10)
color 0b

echo ======================================================================
echo       Typeless 设备标识重置工具 (跳过新手引导版 - Windows 11 / 10)
echo   解决: "The number of users logged into this device has exceeded the limit."
echo ======================================================================
echo.

echo [1/6] 正在关闭 Typeless 客户端进程...
taskkill /f /im Typeless.exe >nul 2>&1
ping 127.0.0.1 -n 2 >nul

echo [2/6] 正在从 Windows 凭据管理器中清除设备标识 (Device ID)...
cmdkey /delete:Typeless.deviceIdentifier >nul 2>&1

echo [3/6] 正在清除本地设备缓存 (device.cache)...
if exist "%APPDATA%\Typeless\Cache\device.cache" del /f /q "%APPDATA%\Typeless\Cache\device.cache" >nul 2>&1

echo [4/6] 正在清理旧登录会话缓存 (保留历史记录与录音)...
if exist "%APPDATA%\Typeless.exe\user-data.json" del /f /q "%APPDATA%\Typeless.exe\user-data.json" >nul 2>&1
if exist "%APPDATA%\Typeless.exe\Local Storage" rd /s /q "%APPDATA%\Typeless.exe\Local Storage" >nul 2>&1
if exist "%APPDATA%\Typeless.exe\Network" del /f /q "%APPDATA%\Typeless.exe\Network\Cookies*" >nul 2>&1
if exist "%APPDATA%\Typeless.exe\.updaterId" del /f /q "%APPDATA%\Typeless.exe\.updaterId" >nul 2>&1

echo [5/6] 正在清理本地配置残留 (写入纯净无 BOM UTF-8)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$p = [System.IO.Path]::Combine($env:APPDATA, 'Typeless.exe', 'app-storage.json'); if (Test-Path $p) { try { $raw = [System.IO.File]::ReadAllText($p); $j = ConvertFrom-Json $raw; if ($j.PSObject.Properties['userData']) { $j.PSObject.Properties.Remove('userData') }; if ($j.PSObject.Properties['quotaUsage']) { $j.PSObject.Properties.Remove('quotaUsage') }; $out = ConvertTo-Json $j -Depth 20; [System.IO.File]::WriteAllText($p, $out) } catch {} }" >nul 2>&1

echo [6/6] 正在预设跳过新手教程 (isCompleted = true)...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ob = [System.IO.Path]::Combine($env:APPDATA, 'Typeless.exe', 'app-onboarding.json'); if (Test-Path $ob) { try { $j = ConvertFrom-Json ([System.IO.File]::ReadAllText($ob)); $j.isCompleted = $true; $j.step = 999; $j.setUpStep = 999; $j.tryItStep = 999; $j.tryItPlaygroundStep = 999; $j.onboardingTryItPlaygroundIsCompleted = $true; $j.onboardingCompletedFloatingBarStart = $true; $j.onboardingCompletedFloatingBarRelease = $true; $j.__ONBOARDING_UPGRADE_NOTICE = $true; $j.onboardingStep = $null; $j.onboardingMaxReachedStep = $null; [System.IO.File]::WriteAllText($ob, (ConvertTo-Json $j -Depth 20)) } catch {} } else { try { $def = '{\"isCompleted\":true,\"step\":999,\"setUpStep\":999,\"tryItStep\":999,\"tryItPlaygroundStep\":999,\"onboardingTryItPlaygroundIsCompleted\":true,\"onboardingCompletedFloatingBarStart\":true,\"onboardingCompletedFloatingBarRelease\":true,\"__ONBOARDING_UPGRADE_NOTICE\":true}'; [System.IO.File]::WriteAllText($ob, $def) } catch {} }" >nul 2>&1

echo.
echo ======================================================================
echo  [√] 重置完成！已彻底解除当前 Windows 设备与旧账号的绑定。
echo.
echo  【说明与提示】
echo  1. 当前为【跳过新手引导教程版】：新账号登录后可直接进入主界面使用。
echo  2. 您的本地历史转写记录与录音文件（typeless.db）已完整保留，不会丢失。
echo  3. 重新启动 Typeless 客户端时，软件会自动生成全新的 Device UUID。
echo  4. 建议使用常规个人邮箱（如 Gmail / Outlook）注册新账号登录，
echo     避免使用临时邮箱或自建域名邮箱（官方已对这些邮箱收紧风控）。
echo ======================================================================
echo.
pause
