#!/bin/bash

echo "Hello! I am ChatGPT in your linux terminal. Ask me anything..."

while true; do

    # Read the user input, also enable arrow navigation
    read -e -p "> " input

    # If the input is empty continue
    if ! [ -n "$input" ]; then
      continue
    fi
    
    echo $input
done