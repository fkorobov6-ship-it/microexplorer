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
    echo -e "${GREEN}MM MM ###  EEEEEE ###  v 1.0${NC}"
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
    echo "  /cd PATH              - change directory (e.g., /cd /home)"
    echo "  /help                 - show this help"
    echo "  /exit                 - quit"
    echo ""
    echo "  (type folder name without slash to go there)"
    echo ""
    read -p "Press Enter to continue..."
}

# Основной цикл
while true; do
    show_banner

    # Вывод команд
    echo "Commands: /back, /create, /open, /edit, /cd, /help, /exit"
    echo ""

    # Ввод пользователя
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
                echo "Usage: /create file NAME or /create folder NAME"
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

    # Пауза перед обновлением экрана
    sleep 1
done
