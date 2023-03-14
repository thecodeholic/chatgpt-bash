#!/bin/bash

url="https://api.openai.com/v1/chat/completions"
apikey="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"

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

install_jq

echo "Hello! I am ChatGPT in your linux terminal. Ask me anything..."

while true; do
    # Read the user input, also enable arrow navigation
    read -e -p "> " input

    # If the input is empty continue
    if ! [ -n "$input" ]; then
      continue
    fi

    # Prepare message(s)
    messages="{\"role\": \"user\", \"content\": \"$input\"}"

    # Prepare request payload data
    data="{\"model\": \"gpt-3.5-turbo\",\"messages\": [$messages]}"

    # Make request to OpenAI API
    response=$(curl $url -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer $apikey" -d "$data" -s )

    error=$(echo "$response" | jq -r '.error.message')
    echo $response
    if [ "$error" != "null" ]; then
        echo -e "${COLOR_RED}!!! ERROR !!!"
        echo -e "$error${COLOR_NC}"
        continue
    fi

    # Get Response, extract content and print
    answer=$(echo "$response" | jq -r '.choices[0].message.content')
    echo -e "$answer"

done