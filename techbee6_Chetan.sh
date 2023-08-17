#!/bin/bash

# Colors
GREEN='\e[0;32m'
RED='\e[0;31m'
NC='\e[0m'
YELLOW='\e[0;33m'
WHITE='\e[1;37m'

# Initialize backup directory
backup_dir="/tmp"

# Flag to track if backup directory is set
backup_dir_set=false

# Function to display menu and take user input
show_menu() {
    echo "--------------------------------------"
    echo -e "${YELLOW}Backup Menu${NC}"
    echo "--------------------------------------"
    echo -e "1. Select backup directory"
    echo -e "2. Provide file path for backup"
    echo -e "3. Check available backups"
    echo -e "4. Quit"
    echo
    echo -ne "${WHITE}Enter your choice: ${NC}"
    read choice
    # Remove leading zeros using sed
    choice=$(echo "$choice" | sed 's/^0*//')
}

# Function to set backup directory
set_backup_directory() {
    echo -e "${WHITE}Enter backup directory path (or press Enter for /tmp): ${NC}"
    read backup_dir_input
    if [ -n "$backup_dir_input" ]; then
        if [ ! -d "$backup_dir_input" ]; then
            mkdir -p "$backup_dir_input"
            echo -e "${GREEN}The directory was not present. It is now created and selected as your default directory.${NC}"
        fi
        backup_dir="$backup_dir_input"
        echo -e "${GREEN}Backup directory set to $backup_dir.${NC}"
        backup_dir_set=true
    else
        echo
        echo -e "${GREEN}You have set the default backup directory as /tmp.${NC}"
        echo
        backup_dir_set=true
    fi
}

# Function to take backup of file with current date appended
take_backup() {
    if [ "$backup_dir_set" = false ]; then
        echo
        echo -e "${RED}Please set the backup directory first in menu option 1.${NC}"
        echo
    else
        echo -e "${WHITE}Enter the path of the file to take backup:${NC}"
        read filepath
        if [ -f "$filepath" ]; then
            echo
            echo -e "${GREEN}Taking backup of $filepath to $backup_dir...${NC}"
            current_date=$(date +"%d-%m-%Y")
            filename=$(basename "$filepath")
            backup_name="${filename}_backup_${current_date}"
            cp "$filepath" "$backup_dir/$backup_name"
            echo -e "${GREEN}The backup of the file is taken successfully.${NC}"
            echo
        else
            echo -e "${RED}File not found.${NC}"
        fi
    fi
}

# Main loop
while true; do
    show_menu
    case $choice in
        1)
            set_backup_directory
            ;;
        2)
            take_backup
            ;;
        3)
            echo -e "${WHITE}Available backups in $backup_dir:${NC}"
            ls -lh "$backup_dir" | grep "_backup_"
            ;;
        4)
            echo -e "${WHITE}Quitting.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please choose a valid option.${NC}"
            ;;
    esac
done