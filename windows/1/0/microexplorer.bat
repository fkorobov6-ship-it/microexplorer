@echo off
color 60
title MicroExplorer
chcp 65001 >nul
setlocal enabledelayedexpansion

cd /d C:\
set "prev_dir="

:show
cls
color 60
echo MM      MM       EEEEEE
echo MMMM  MMMM       EE
echo MM  MM  MM       EEEEEE
echo MM      MM  ###  EE      ###
echo MM      MM  ###  EEEEEE  ###      v 1
echo.
timeout /t 1 /nobreak >nul
echo Current: %cd%
dir /w

:loop
echo.
echo Commands:
echo   /back                 go to previous directory
echo   /create file NAME     create a new file
echo   /create folder NAME   create a new folder
echo   /open FILE            open FILE with default app
echo   /edit [FILE]          edit FILE with Notepad (waits for close)
echo   /cd DRIVE:            change drive (e.g. /cd D:)
echo   /help                 show this help
echo   /exit                 quit
echo.
echo (type folder name without slash to go there)
echo.
set /p "input=> "

if "!input:~0,1!" neq "/" (
    if not "!input!"=="" (
        set "old_dir=!cd!"
        cd /d "!input!" 2>nul
        if errorlevel 1 (
            echo Cannot go to "!input!"
        ) else (
            set "prev_dir=!old_dir!"
        )
    )
    goto show
)

set "cmd=!input!"

if /i "!cmd!"=="/exit" color 0f && cls && exit /b

if /i "!cmd!"=="/back" (
    if not "!prev_dir!"=="" (
        set "temp=!cd!"
        cd /d "!prev_dir!" 2>nul
        if errorlevel 1 (
            echo Can't go back to "!prev_dir!"
            set "prev_dir=!temp!"
        ) else (
            set "prev_dir=!temp!"
        )
    ) else (
        echo No previous directory.
    )
    goto show
)

if /i "!cmd:~0,8!"=="/create " (
    set "args=!cmd:~8!"
    call :create !args!
    goto show
)

if /i "!cmd!"=="/help" (
    call :show_help
    goto show
)

if /i "!cmd:~0,4!"=="/cd " (
    set "drive=!cmd:~4!"
    call :change_drive "!drive!"
    goto show
)

if /i "!cmd:~0,6!"=="/open " (
    set "file=!cmd:~6!"
    call :open_file "!file!"
    goto show
)

if /i "!cmd!"=="/edit" (
    call :edit_without_arg
    goto show
)

if /i "!cmd:~0,6!"=="/edit " (
    set "raw_file=!cmd:~6!"
    for /f "tokens=*" %%F in ("!raw_file!") do set "file=%%F"
    call :edit_with_arg "!file!"
    goto show
)

echo Unknown command: "!input!"
goto show

:create
set "type=%~1"
set "name=%~2"
if "!type!"=="" (
    echo Usage: /create file NAME   or   /create folder NAME
    goto :eof
)
if /i "!type!"=="folder" (
    if not "!name!"=="" (
        mkdir "!name!" 2>nul
        if errorlevel 1 ( echo Failed to create folder "!name!" ) else ( echo Folder "!name!" created. )
    ) else (
        echo Missing folder name.
    )
    goto :eof
)
if /i "!type!"=="file" (
    if not "!name!"=="" (
        echo.>>"!name!" 2>nul
        if errorlevel 1 ( echo Failed to create file "!name!" ) else ( echo File "!name!" created. )
    ) else (
        echo Missing file name.
    )
    goto :eof
)
echo Unknown type "!type!". Use 'file' or 'folder'.
goto :eof

:show_help
echo.
echo Available commands:
echo   /back                 - go to previous directory
echo   /create file ^<name^>   - create a new file
echo   /create folder ^<name^> - create a new folder
echo   /open ^<file^>          - open file with default program
echo   /edit [^<file^>]        - edit file with Notepad (waits for close)
echo   /cd ^<drive^>:          - switch to another drive
echo   /help                 - show this help
echo   /exit                 - quit
echo   ^<folder name^>          - just type folder name to go there
pause
goto :eof

:change_drive
set "drive=%~1"
if not "!drive!"=="" (
    cd /d "!drive!" 2>nul
    if errorlevel 1 ( echo Cannot change drive to "!drive!" ) else ( set "prev_dir=!cd!" )
) else (
    echo Usage: /cd D:
)
goto :eof

:open_file
set "file=%~1"
if not "!file!"=="" (
    if exist "!file!" (
        start "" "!file!" 2>nul
        if errorlevel 1 ( echo Cannot open "!file!" ) else ( echo Opening "!file!"... )
    ) else (
        echo File "!file!" not found.
    )
) else (
    echo Usage: /open filename.ext
)
goto :eof

:edit_without_arg
set /p "edit_file=Enter file name: "
if "!edit_file!"=="" goto :eof
call :run_notepad "!edit_file!"
goto :eof

:edit_with_arg
set "file=%~1"
if "!file!"=="" goto :eof
call :run_notepad "!file!"
goto :eof

:run_notepad
set "target_file=%~1"
echo Opening Notepad with "%target_file%"...
start /wait notepad "%target_file%"
goto :eof
