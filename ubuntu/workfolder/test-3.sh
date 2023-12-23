#!/bin/bash

# Display first three parametrs
echo "Parameter 1: ${1}"
echo "Parameter 2: ${2}"
echo "Parameter 3: ${3}"

# loop through all the position parametrs
while [ ${#} -gt 0 ]
do
    echo "Number of param: ${#}"
    echo "param 1: ${1}"
    echo "param 2: ${2}"
    echo "param 3: ${3}"
    shift
done

