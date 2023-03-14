#!/bin/bash

url="https://api.openai.com/v1/chat/completions"
apikey="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"

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

    echo $response
done