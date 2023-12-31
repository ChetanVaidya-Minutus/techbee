#!/bin/bash

GREEN='\e[0;32m'
RED='\e[0;31m'
NC='\e[0m'
YELLOW='\e[0;33m'
PINK='\e[38;5;206m'
WHITE='\e[1;37m'

password_set=false
current_password=""
security_question_set=false
security_question=""
security_question_answer=""

# Function to check password strength
check_password_strength() {
    password=$1
    is_new_password=$2

    # Check minimum length of 10 characters
    if [[ ${#password} -lt 10 || !($password =~ [a-z] && $password =~ [A-Z]) ]]; then
        echo -e "${RED}Password must be at least 10 characters long and contain both lowercase and uppercase letters."
        return 1
    fi

    # Additional password strength checks can be added here

    if [ "$is_new_password" == "true" ]; then
        # Password meets all requirements
        echo
        echo -e "${GREEN}Congrats....your password is strong."
		echo
    fi

    return 0
}

# Function to set security question
set_security_question() {
    if $security_question_set; then
        echo -e "${RED}Security question has already been set. You cannot set it again.${NC}"
        return
    fi

    echo -e "${GREEN}Set your security question:"
    read -p "Security Question: " question

    # Change the color of the answer input to white
    echo -e -n "${WHITE}"
    read -p "Answer: " answer
    echo -e -n "${NC}"

    security_question_set=true
    security_question="$question"
    security_question_answer="$answer"
    echo -e "${GREEN}Security question set successfully."
}

# Function to prompt and verify security question
verify_security_question() {
    echo -e "${YELLOW}Please answer the security question to verify your identity:"
    echo -e "Question: ${security_question} ${WHITE}(Enter your answer below)"
    read -s -p "Answer: " entered_answer
    echo -e -n "${NC}"

    if [[ "$entered_answer" == "$security_question_answer" ]]; then
        echo -e "${GREEN}Identity verified."
    else
        echo -e "${RED}Incorrect answer. Identity verification failed."
        verify_security_question  # Prompt again for entering the answer
    fi
}

# Main script
while true; do
    echo -e "${NC}-----------------------------------------------"
    echo -e "${GREEN}Please select an option:"
    echo -e "${NC}-----------------------------------------------"
    echo
    echo -e "${YELLOW}1) Set security question${NC}"
    echo -e "${YELLOW}2) Generate your new password${NC}"
    echo -e "${YELLOW}3) Check your current password${NC}"
    echo -e "${YELLOW}4) Quit${NC}"
    echo
    read -p "Enter your choice: " choice
    echo

    # Remove leading zeros using sed
    choice=$(echo "$choice" | sed 's/^0*//')

    case "$choice" in
        1)
            set_security_question
            ;;
        2)
            if ! $security_question_set; then
                echo -e "${RED}Security question has not been set. Please set the security question first.${NC}"
                continue
            fi

            verify_security_question

            read -s -p "Generate your new password: " new_password
            echo # Move to a new line after password input

            # Check for spaces in the password
            if [[ "$new_password" == *" "* ]]; then
                echo -e "${RED}You have added a space in the password. Please enter a new password without spaces.${NC}"
                continue
            fi

            check_password_strength "$new_password" "true"
            if [ $? -eq 0 ]; then
                current_password="$new_password"
                password_set=true
            fi
            ;;
        3)
            if ! $security_question_set; then
                echo -e "${RED}Security question has not been set. Please set the security question first.${NC}"
                continue
            fi

            verify_security_question

            if ! $password_set; then
                echo -e "${RED}You have not set any password yet. Please set your new password first.${NC}"
                read -s -p "Set your new password: " new_password
                echo # Move to a new line after password input

                # Check for spaces in the password
                if [[ "$new_password" == *" "* ]]; then
                    echo -e "${RED}You have added a space in the password. Please enter a new password without spaces.${NC}"
                    continue
                fi

                check_password_strength "$new_password" "true"
                if [ $? -eq 0 ]; then
                    current_password="$new_password"
                    password_set=true
                fi
            else
                echo -e "${PINK}Checking current password..."
                echo -e "Current Password: ${WHITE}${current_password}${NC}"
                check_password_strength "$current_password" "false"
            fi
            ;;
        4)
            echo -e "${NC}Quitting..."
            break
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again."
            ;;
    esac
done
