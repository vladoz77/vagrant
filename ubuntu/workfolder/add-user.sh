#!/usr/bin/bash

# Ask username
read -p 'Enter username: ' USER_NAME

# Ask real name
read -p 'Enter real name : ' USER

# Ask password
read -p 'Enter password: ' PASS

# Add user
useradd -c "${USER}" -m "${USER_NAME}"

# Add password
echo "${USER_NAME}":"${PASS}" | chpasswd

# Change pass by first login
passwd -e "${USER_NAME}"

echo User "${USER_NAME}" created
 