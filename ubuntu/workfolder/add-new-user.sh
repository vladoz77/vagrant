#!/bin/bash

# Make sure the script start from root
if [ ${UID} -ne 0 ]; then
echo "Please start script from root"
exit 1
fi

# Check if has arguments
if [ ${#} -eq 0 ]; then
echo "Please enter username"
exit 1
fi


# First param is username
USERNAME=${1}
COMMENT=${2}
PASSWORD="$(date +%N%s| sha256sum | head -c8)"

# Check if user exist
id ${USERNAME} > /dev/null 2>&1
if [ ${?} -eq 0 ]; then
echo "User ${USERNAME} is exist"
exit 1
fi

# Create user
useradd -m -c ${COMMENT} -s /bin/bash  ${USERNAME}
echo "${USERNAME}":"${PASSWORD}" | chpasswd

# Change pass by first login
passwd -e "${USERNAME}" > /dev/null 2>&1

# user info
echo "username is: ${USERNAME}"
echo "password is: ${PASSWORD}"

