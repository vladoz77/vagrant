#! /bin/bash
i=0

# While loop with break
while [[ ${i} -le 5 ]]
do 
    echo "Number is ${i}"
    i=$((${i}+1))
    if [[ ${i} == 3 ]]; then
      break
    fi
done

