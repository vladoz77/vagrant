#!/usr/bin/bash
# Check root user
if [ ${UID} -ne 0 ]
then 
  echo Login by root user
  exit 1
fi


# Ask username
read -p 'Enter username: ' USER_NAME
id -u $USER_NAME  > /dev/null 2>&1
if [ ${?} -eq 0 ]
then 
  echo 'user exist, try new name'
  exit 1
fi

# Ask real name
read -p 'Enter real name : ' USER

# Ask password
read -p 'Enter password: ' PASS

# Add user
useradd -c "${USER}" -m "${USER_NAME}"
if [ ${?} -ne 0 ]
then 
  echo 'User did not create'
  exit 1
fi

# Add password
echo "${USER_NAME}":"${PASS}" | chpasswd

# Change pass by first login
passwd -e "${USER_NAME}"

echo User "${USER_NAME}" created
exit 0
 