#!/usr/bin/bash

# This script generates a random password for each user specified on the command line

# Display what the user typed on cli
echo "You executed command: ${0}"

# Display path and filename the script
echo path is $(dirname ${0}) ans filename is $(basename ${0})

# Tell how many arguments they passed in.
NUMBER_OF_PARAMETRS="${#}"
echo "You supplied ${NUMBER_OF_PARAMETRS}"
if [ ${NUMBER_OF_PARAMETRS} -lt 1 ]
then
	echo ${0} USER_NAME [USER]
	exit 1
fi

# Generate password for each parametrs
for USER_NAME in "${@}"
do 
   PASSWORD=$(date +%s%N | sha256sum | head -c8)
   echo "${USER_NAME}: ${PASSWORD}"
done
