@echo off

:: BatchGotAdmin Borrowed from Eneerge @ https://sites.google.com/site/eneerge/scripts/batchgotadmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------    

::Borrowed from @abbodi1406's scripts
for /f "tokens=6 delims=[]. " %%i in ('ver') do set build=%%i
if %build% LSS 17763 (
    echo =============================================================
    echo "此腳本僅支援 Windows 10 RS5 (1809) 或更新的系統，按Enter結束"
    echo =============================================================
    echo.
    pause
    goto :EOF
)
echo %build%

:START_SCRIPT
set "scriptver=2.5.0-tc"
set "FlightSigningEnabled=0"
bcdedit /enum {current} | findstr /I /R /C:"^flightsigning *Yes$" >NUL 2>&1
IF %ERRORLEVEL% EQU 0 set "FlightSigningEnabled=1"

:CHOICE_MENU
cls
set "choice="
echo OfflineInsiderEnroll v%scriptver% / 繁體中文翻譯 by Kevinowo
echo.
echo 1 - 將更新頻道改為 Dev 頻道
echo 2 - 將更新頻道改為 Beta 頻道 (建議選項)
echo 3 - 將更新頻道改為 Release Preview 頻道
echo.
echo 4 - 停止接收預覽更新
echo 5 - 不執行任何動作並關閉腳本
echo.
set /p choice="選項 (1-5): "
echo.
if /I "%choice%"=="1" goto :ENROLL_DEV
if /I "%choice%"=="2" goto :ENROLL_BETA
if /I "%choice%"=="3" goto :ENROLL_RP
if /I "%choice%"=="4" goto :STOP_INSIDER
if /I "%choice%"=="5" goto :EOF
goto :CHOICE_MENU

:ENROLL_RP
set "Channel=ReleasePreview"
set "Fancy=Release Preview 頻道"
set "BRL=8"
goto :ENROLL

:ENROLL_BETA
set "Channel=Beta"
set "Fancy=Beta 頻道"
set "BRL=4"
goto :ENROLL

:ENROLL_DEV
set "Channel=Dev"
set "Fancy=Dev 頻道"
set "BRL=2"
goto :ENROLL

:RESET_INSIDER_CONFIG
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Account" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Cache" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingPreview" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderSlow" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingInsiderFast" /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /f
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v BranchReadinessLevel /f
goto :EOF

:ADD_INSIDER_CONFIG
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Orchestrator" /t REG_DWORD /v EnableUUPScan /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\RingExternal" /t REG_DWORD /v Enabled /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\SLS\Programs\WUMUDCat" /t REG_DWORD /v WUMUDCATEnabled /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v EnablePreviewBuilds /d 2 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v IsBuildFlightingEnabled /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v IsConfigSettingsFlightingEnabled /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v TestFlags /d 32 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_DWORD /v RingId /d 11 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_SZ /v Ring /d "External" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_SZ /v ContentType /d "Mainline" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\Applicability" /t REG_SZ /v BranchName /d "%Channel%" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /t REG_SZ /v StickyXaml /d "<StackPanel xmlns="^""http://schemas.microsoft.com/winfx/2006/xaml/presentation"^""><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">此裝置的更新頻道已交由 OfflineInsiderEnroll v%scriptver% 管理。</TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">若您想要更改更新頻道或停止接收更新, 請再次開啟 OfflineInsiderEnroll 腳本 <Hyperlink NavigateUri="^""https://github.com/kevin0216/offlineinsiderenroll/blob/master/readme.md"^"" TextDecorations="^""None"^"">了解更多</Hyperlink></TextBlock><TextBlock Text="^""目前加入的更新頻道"^"" Margin="^""0,20,0,10"^"" Style="^""{StaticResource SubtitleTextBlockStyle}"^"" /><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"" Margin="^""0,0,0,5"^""><Run FontFamily="^""Segoe MDL2 Assets"^"">&#xECA7;</Run> <Span FontWeight="^""SemiBold"^"">%Fancy%</Span></TextBlock><TextBlock Text="^""更新頻道: %Channel%"^"" Style="^""{StaticResource BodyTextBlockStyle }"^"" /><TextBlock Text="^""內容: Mainline"^"" Style="^""{StaticResource BodyTextBlockStyle }"^"" /><TextBlock Text="^""關於診斷/遙測設定"^"" Margin="^""0,20,0,10"^"" Style="^""{StaticResource SubtitleTextBlockStyle}"^"" /><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">測試人員計畫需要您的診斷資料設定為 <Span FontWeight="^""SemiBold"^"">傳送完整資料</Span>，您可以至 <Span FontWeight="^""SemiBold"^"">診斷與意見</Span> 來進行驗證及更改相關設定是否已設定成功。</TextBlock><Button Command="^""{StaticResource ActivateUriCommand}"^"" CommandParameter="^""ms-settings:privacy-feedback"^"" Margin="^""0,10,0,0"^""><TextBlock Margin="^""5,0,5,0"^"">開啟 診斷與意見</TextBlock></Button><TextBlock Text="^""關於管理單位"^"" Margin="^""0,20,0,10"^"" Style="^""{StaticResource SubtitleTextBlockStyle}"^"" /><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">管理單位: OfflineInsiderEnroll v%scriptver% 繁體中文版</TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">原作: abbodi1406 <Hyperlink NavigateUri="^""https://github.com/abbodi1406/"^"" TextDecorations="^""None"^"">Github</Hyperlink></TextBlock><TextBlock Style="^""{StaticResource BodyTextBlockStyle }"^"">翻譯: 凱文 Kevinowo <Hyperlink NavigateUri="^""https://github.com/kevin0216/"^"" TextDecorations="^""None"^"">Github</Hyperlink></TextBlock></StackPanel>" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIHiddenElements /d 65535 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIDisabledElements /d 65535 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIServiceDrivenElementVisibility /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIErrorMessageVisibility /d 192 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /t REG_DWORD /v AllowTelemetry /d 3 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /t REG_DWORD /v BranchReadinessLevel /d %BRL% /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Strings" /t REG_SZ /v StickyMessage /d "{"^""Message"^"":"^""此裝置的更新頻道已交由 OfflineInsiderEnroll 控制"^"","^""LinkTitle"^"":"^"""^"","^""LinkUrl"^"":"^"""^"","^""DynamicXaml"^"":"^""<StackPanel xmlns=\\"^""http://schemas.microsoft.com/winfx/2006/xaml/presentation\\"^""><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"">此裝置的更新頻道已交由 OfflineInsiderEnroll v%scriptver% 管理。</TextBlock><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"">若您想要更改更新頻道或停止接收更新, 請再次開啟 OfflineInsiderEnroll 腳本 <Hyperlink NavigateUri=\\"^""https://github.com/kevin0216/offlineinsiderenroll/blob/master/readme.md\\"^"" TextDecorations=\\"^""None\\"^"">了解更多</Hyperlink></TextBlock><TextBlock Text=\\"^""目前加入的更新頻道\\"^"" Margin=\\"^""0,20,0,10\\"^"" Style=\\"^""{StaticResource SubtitleTextBlockStyle}\\"^"" /><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"" Margin=\\"^""0,0,0,5\\"^""><Run FontFamily=\\"^""Segoe MDL2 Assets\\"^"">&#xECA7;</Run> <Span FontWeight=\\"^""SemiBold\\"^"">%Fancy%</Span></TextBlock><TextBlock Text=\\"^""更新頻道: %Channel%\\"^"" Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"" /><TextBlock Text=\\"^""內容: Mainline\\"^"" Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"" /><TextBlock Text=\\"^""關於診斷/遙測設定\\"^"" Margin=\\"^""0,20,0,10\\"^"" Style=\\"^""{StaticResource SubtitleTextBlockStyle}\\"^"" /><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"">測試人員計畫需要您的診斷資料設定為 <Span FontWeight=\\"^""SemiBold\\"^"">傳送完整資料</Span>，您可以至 <Span FontWeight=\\"^""SemiBold\\"^"">診斷與意見反饋 </Span>來進行驗證及更改相關設定是否已設定成功。</TextBlock><Button Command=\\"^""{StaticResource ActivateUriCommand}\\"^"" CommandParameter=\\"^""ms-settings:privacy-feedback\\"^"" Margin=\\"^""0,10,0,0\\"^""><TextBlock Margin=\\"^""5,0,5,0\\"^"">開啟 診斷與意見反饋</TextBlock></Button><TextBlock Text=\\"^""關於管理單位\\"^"" Margin=\\"^""0,20,0,10\\"^"" Style=\\"^""{StaticResource SubtitleTextBlockStyle}\\"^"" /><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"">管理單位: OfflineInsiderEnroll v%scriptver% 繁體中文版</TextBlock><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"">原作: abbodi1406 <Hyperlink NavigateUri=\\"^""https://github.com/abbodi1406/\\"^"" TextDecorations=\\"^""None\\"^"">Github</Hyperlink></TextBlock><TextBlock Style=\\"^""{StaticResource BodyTextBlockStyle }\\"^"">翻譯: 凱文 Kevinowo <Hyperlink NavigateUri=\\"^""https://github.com/kevin0216/\\"^"" TextDecorations=\\"^""None\\"^"">Github</Hyperlink></TextBlock></StackPanel>"^"","^""Severity"^"":0}" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIHiddenElements_Rejuv /d 65534 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility" /t REG_DWORD /v UIDisabledElements_Rejuv /d 65535 /f
goto :EOF

:ENROLL
echo 您選擇了加入 %Fancy%，正在套用設定...
call :RESET_INSIDER_CONFIG 1>NUL 2>NUL
call :ADD_INSIDER_CONFIG 1>NUL 2>NUL
bcdedit /set {current} flightsigning yes >NUL 2>&1
echo 設定已完成，請按任意鍵結束。

echo.
IF %FlightSigningEnabled% NEQ 1 goto :ASK_FOR_REBOOT
pause
goto :EOF

:STOP_INSIDER
echo 您選擇了停止接收更新，正在套用設定
call :RESET_INSIDER_CONFIG 1>NUL 2>NUL
bcdedit /deletevalue {current} flightsigning >NUL 2>&1
echo 設定已完成，請按任意鍵結束。

echo.
IF %FlightSigningEnabled% NEQ 0 goto :ASK_FOR_REBOOT
pause
goto :EOF

:ASK_FOR_REBOOT
set "choice="
echo 需要重新開機以套用設定。
set /p choice="您想要現在重新開機嗎? (y/N) "
if /I "%choice%"=="y" shutdown -r -t 0
goto :EOF
