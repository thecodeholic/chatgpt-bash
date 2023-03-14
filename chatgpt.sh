#!/bin/bash

file_path=~/.openapi.json
url="https://api.openai.com/v1/chat/completions"
apikey=

# Define red color code
COLOR_RED='\033[0;31m'

# Define reset color code
COLOR_NC='\033[0m'

install_jq() {
    # Check if jq command is available
    if command -v jq > /dev/null; then
        return 0
    else
        echo -e "${COLOR_RED}\"jq\" is required to run this script. Exiting...${COLOR_NC}"
        exit 1
    fi
}

read_api_key() {
    while true; do
        # If file exists that should contain apikey
        if test -f $file_path; then
            # We read that file and retun from the function
            apikey=$(cat $file_path | jq -r '.apikey')

            return 0
        else
            # If file does not exist we ask user to enter his api key
            read -p "Please enter your OpenAI API Key > " apikey

            # If user entered non empty apikey we save that in $file_path location
            if [ -n "$apikey" ]; then
                echo "Your API key was stored in \"$file_path\" for later usage"
                echo "{\"apikey\": \"$apikey\"}" > $file_path
                return 0
            fi
        fi

    done

}


show_loader() {
  # Start the loader animation
  spinner="/-\|"
  while :
  do
    for i in $(seq 0 3); do
      # Print character on the same line
      echo -ne "\r${spinner:$i:1}  "
      sleep 0.1
    done
  done &
}

stop_loader() {
  # Stop the loader animation
  kill $! &> /dev/null
}


install_jq

read_api_key

echo "Hello! I am ChatGPT in your linux terminal. Ask me anything..."

# Define the behavior of chat
messages='{"role": "system", "content": "You are a helpful assistant."}'

while true; do
    # Read the user input, also enable arrow navigation
    read -e -p "> " input

    # If the input is empty continue
    if ! [ -n "$input" ]; then
      continue
    fi

    # Prepare message(s)
    messages="$messages,{\"role\": \"user\", \"content\": \"$input\"}"

    # Prepare request payload data
    data="{\"model\": \"gpt-3.5-turbo\",\"messages\": [$messages]}"

    show_loader

    # Make request to OpenAI API
    response=$(curl $url -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $apikey" -d "$data" -s )

    stop_loader
    
    # Move cursor on the same line at the beginning
    echo -ne "\r"

    error=$(echo "$response" | jq -r '.error.message')
    
    if [ "$error" != "null" ]; then
        echo -e "${COLOR_RED}!!! ERROR !!!"
        echo -e "$error${COLOR_NC}"
        continue
    fi

    # Get Response, extract content and print
    answer=$(echo "$response" | jq -r '.choices[0].message.content')
    echo -e "$answer"

    # Prepare new message
    new_message="{\"role\": \"assistant\", \"content\": \"$answer\"}"

    # Append new message into all messages
    messages="$messages,$new_message"

done