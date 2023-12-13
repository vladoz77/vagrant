#!/bin/bash

# Create password 
PASSWORD=${RANDOM}
echo "${PASSWORD}"

# Create better password
PASSWORD=$(date +%s%N)
echo "${PASSWORD}"

# Create very good pass
PASSWORD=$(date +%s$N | sha1sum | head -c8)
echo "${PASSWORD}"