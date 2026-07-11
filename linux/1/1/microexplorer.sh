#!/bin/bash

# Цвета и настройки
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Переменные для навигации
prev_dir=""

# Функция отображения баннера
show_banner() {
    clear
    echo -e "${GREEN}MM MM     EEEEEE${NC}"
    echo -e "${GREEN}MMMM MMMM  EE${NC}"
    echo -e "${GREEN}MM MM MM   EEEEEE${NC}"
    echo -e "${GREEN}MM MM ###  EE ###${NC}"
    echo -e "${GREEN}MM MM ###  EEEEEE ###  v 1.1${NC}"
    echo ""
    sleep 0.5
    echo -e "${YELLOW}Current: $(pwd)${NC}"
    ls -la --color=auto
    echo ""
}

# Функция показа помощи
show_help() {
    echo ""
    echo "Available commands:"
    echo "  /back                 - go to previous directory"
    echo "  /create file NAME     - create a new file"
    echo "  /create folder NAME   - create a new folder"
    echo "  /open FILE            - open FILE with default app"
    echo "  /edit [FILE]          - edit FILE with nano (waits for close)"
    echo "  /delete FILE          - delete a file"
    echo "  /delete folder FOLDER - delete a folder and all its contents"
    echo "  /download URL [FILE]  - download file from the Internet"
    echo "  /cd PATH              - change directory (e.g., /cd /home)"
    echo "  /help                 - show this help"
    echo "  /exit                 - quit"
    echo ""
    echo "  (type folder name without slash to go there)"
    echo ""
    read -p "Press Enter to continue..."
}

# Функция удаления файла
delete_file() {
    local file="$1"
    if [[ -z "$file" ]]; then
        echo -e "${RED}Usage: /delete filename${NC}"
        return
    fi
    if [[ ! -f "$file" ]]; then
        echo -e "${RED}File '$file' not found.${NC}"
        return
    fi
    if rm -f "$file" 2>/dev/null; then
        echo -e "${GREEN}Deleted '$file'${NC}"
    else
        echo -e "${RED}Failed to delete '$file'${NC}"
    fi
}

# Функция удаления папки
delete_folder() {
    local folder="$1"
    if [[ -z "$folder" ]]; then
        echo -e "${RED}Usage: /delete folder FOLDER${NC}"
        return
    fi
    if [[ ! -d "$folder" ]]; then
        echo -e "${RED}Folder '$folder' not found.${NC}"
        return
    fi
    if rm -rf "$folder" 2>/dev/null; then
        echo -e "${GREEN}Deleted folder '$folder'${NC}"
    else
        echo -e "${RED}Failed to delete folder '$folder'${NC}"
    fi
}

# Функция скачивания файла
download_file() {
    local url="$1"
    local fname="$2"
    if [[ -z "$url" ]]; then
        echo -e "${RED}Usage: /download URL [filename]${NC}"
        return
    fi
    if [[ -z "$fname" ]]; then
        fname="downloaded_file"
    fi
    echo -e "${GREEN}Downloading from $url to '$fname' ...${NC}"
    if curl -L -o "$fname" "$url" 2>/dev/null; then
        echo -e "${GREEN}Downloaded to '$fname'${NC}"
    else
        echo -e "${RED}Download failed. Check URL and network.${NC}"
    fi
}

# Основной цикл
while true; do
    show_banner

    echo "Commands: /back, /create, /open, /edit, /delete, /download, /cd, /help, /exit"
    echo ""

    read -p "> " input

    # Обработка команд
    case "$input" in
        /exit)
            clear
            exit 0
            ;;
        /back)
            if [[ -n "$prev_dir" ]]; then
                temp="$(pwd)"
                if cd "$prev_dir" 2>/dev/null; then
                    prev_dir="$temp"
                else
                    echo -e "${RED}Can't go back to '$prev_dir'${NC}"
                    prev_dir="$temp"
                fi
            else
                echo -e "${RED}No previous directory.${NC}"
            fi
            ;;
        /create\ *)
            args="${input#/create }"
            type=$(echo "$args" | cut -d' ' -f1)
            name=$(echo "$args" | cut -d' ' -f2-)
            if [[ -z "$type" ]]; then
                echo -e "${RED}Usage: /create file NAME or /create folder NAME${NC}"
            elif [[ "$type" == "folder" ]]; then
                if [[ -n "$name" ]]; then
                    if mkdir -p "$name" 2>/dev/null; then
                        echo -e "${GREEN}Folder '$name' created.${NC}"
                    else
                        echo -e "${RED}Failed to create folder '$name'${NC}"
                    fi
                else
                    echo -e "${RED}Missing folder name.${NC}"
                fi
            elif [[ "$type" == "file" ]]; then
                if [[ -n "$name" ]]; then
                    if touch "$name" 2>/dev/null; then
                        echo -e "${GREEN}File '$name' created.${NC}"
                    else
                        echo -e "${RED}Failed to create file '$name'${NC}"
                    fi
                else
                    echo -e "${RED}Missing file name.${NC}"
                fi
            else
                echo -e "${RED}Unknown type '$type'. Use 'file' or 'folder'.${NC}"
            fi
            ;;
        /open\ *)
            file="${input#/open }"
            if [[ -n "$file" ]]; then
                if [[ -e "$file" ]]; then
                    echo -e "${GREEN}Opening '$file'...${NC}"
                    xdg-open "$file" 2>/dev/null || echo -e "${RED}Cannot open '$file'${NC}"
                else
                    echo -e "${RED}File '$file' not found.${NC}"
                fi
            else
                echo -e "${RED}Usage: /open filename.ext${NC}"
            fi
            ;;
        /edit)
            read -p "Enter file name: " edit_file
            if [[ -n "$edit_file" ]]; then
                echo -e "${GREEN}Opening nano with '$edit_file'...${NC}"
                nano "$edit_file"
            fi
            ;;
        /edit\ *)
            file="${input#/edit }"
            if [[ -n "$file" ]]; then
                echo -e "${GREEN}Opening nano with '$file'...${NC}"
                nano "$file"
            else
                echo -e "${RED}Usage: /edit [FILE]${NC}"
            fi
            ;;
        /delete\ *)
            args="${input#/delete }"
            subcmd=$(echo "$args" | cut -d' ' -f1)
            arg=$(echo "$args" | cut -d' ' -f2-)
            if [[ "$subcmd" == "folder" ]]; then
                delete_folder "$arg"
            else
                delete_file "$args"
            fi
            ;;
        /download\ *)
            rest="${input#/download }"
            url=$(echo "$rest" | cut -d' ' -f1)
            fname=$(echo "$rest" | cut -d' ' -f2-)
            download_file "$url" "$fname"
            ;;
        /cd\ *)
            path="${input#/cd }"
            if [[ -n "$path" ]]; then
                if cd "$path" 2>/dev/null; then
                    prev_dir="$(pwd)"
                else
                    echo -e "${RED}Cannot change directory to '$path'${NC}"
                fi
            else
                echo -e "${RED}Usage: /cd PATH${NC}"
            fi
            ;;
        /help)
            show_help
            ;;
        /*)
            echo -e "${RED}Unknown command: '$input'${NC}"
            ;;
        *)
            if [[ -n "$input" ]]; then
                old_dir="$(pwd)"
                if cd "$input" 2>/dev/null; then
                    prev_dir="$old_dir"
                else
                    echo -e "${RED}Cannot go to '$input'${NC}"
                fi
            fi
            ;;
    esac

    sleep 1
done
