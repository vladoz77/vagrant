#!/bin/bash
# Make sure the script start from root
if [ ${UID} -ne 0 ]; then
echo "Please start script from root"
exit 1
fi

# Check if has arguments
if [ ${#} -lt 1 ]; then
echo "Please enter username"
exit 1
fi

# First param is username, comment, password
USERNAME=${1}

# Add comment line
shift
COMMENT=${@}

# Generate password
PASSWORD="$(date +%N%s| sha256sum | head -c8)"

# Check if user exist
if id ${USERNAME} > /dev/null 2>&1; then
echo "User ${USERNAME} is exist"
exit 1
fi

# Create user
useradd -m -c "${COMMENT}" -s /bin/bash "${USERNAME}"
echo "${USERNAME}":"${PASSWORD}" | chpasswd

# Change pass by first login
passwd -e "${USERNAME}" > /dev/null

# user info
echo "username: ${USERNAME}"
echo "password: ${PASSWORD}"

