@echo off
setlocal
cd /d "%~dp0"
dotnet restore Client.Windows.sln --configfile NuGet.config -p:Platform=x64
if errorlevel 1 pause & exit /b 1
start "" Client.Windows.sln
