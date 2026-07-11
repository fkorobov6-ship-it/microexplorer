@echo off
chcp 65001 >nul
set /p "selectedbyuser=In where install M.E? (without naming a name of a program folder, e.g. C:\): "
cd /d "%selectedbyuser%"
set /p "folderbyuser=Name of a folder?: "
if not exist "%folderbyuser%" mkdir "%folderbyuser%"
cd /d "%folderbyuser%"
echo Installing... (from website of project)
curl -L "https://microexplorer.website.yandexcloud.net/microexplorer.bat" -o "microexplorer.bat"
if errorlevel 1 ( echo Error & pause >nul & exit /b )
echo Continuing...
echo if you see an error close installer, if all is ok then continue setup by pressing any key.
pause >nul
set "INSTALL_DIR=%CD%"
setx PATH "%PATH%;%CD%"
echo.
echo if ME dont start with "microexplorer" in cmd then start "sysdm.cpl", Advanced, Enviroment Variables, and add in variable "PATH" path to ME and save. Thats all!
echo.
echo M.E Ready for use
echo.
echo.
pause >nul
