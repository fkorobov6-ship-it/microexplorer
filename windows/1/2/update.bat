@echo off
for /f "delims=" %%v in ('curl -s https://raw.githubusercontent.com/fkorobov6-ship-it/microexplorer/refs/heads/main/newversion') do set "new_version=%%v"
if "%new_version%"=="" echo Failed to get version. & pause & exit /b
set "url=https://raw.githubusercontent.com/fkorobov6-ship-it/microexplorer/refs/heads/main/windows/%new_version%/microexplorer.bat"
curl -L -o microexplorer_new.bat "%url%"
if not exist microexplorer_new.bat echo Download error! & pause & exit /b
move /y microexplorer_new.bat microexplorer.bat
echo Update complete!
pause
