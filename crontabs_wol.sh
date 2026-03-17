#!/bin/sh

TOKEN="GITHUB_TOKEN"
REPO="Mowei/wol"
FILE_PATH="list"
API_URL="https://api.github.com/repos/$REPO/contents/$FILE_PATH"

MAC_MSI="30:9C:23:14:0D:FF"
MAC_WORK="3C:7C:3F:F2:69:4E"

response=$(curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$API_URL")
encoded_content=$(echo "$response" | grep '"content":' | cut -d'"' -f4 | tr -d '\n')
sha=$(echo "$response" | grep '"sha":' | cut -d'"' -f4)

if [ -z "$encoded_content" ]; then
    exit 1
fi

content=$(echo "$encoded_content" | base64 -d)

if echo "$content" | grep -q " 1"; then    
    echo "$content" | while read -r name status; do
        if [ "$status" = "1" ]; then
            case "$name" in
                "MSI")  mac="$MAC_MSI" ;;
                "WORK") mac="$MAC_WORK" ;;
                *)      mac="$name" ;;
            esac

            if [ -n "$mac" ]; then
                curl -k -s -X GET "https://127.0.0.1:8443/wol_action.asp?dstmac=$mac" > /dev/null
            fi
        fi
    done

    new_content=$(echo "$content" | sed 's/ 1/ 0/g')
    new_encoded=$(echo -n "$new_content" | base64 | tr -d '\n')

    curl -s -X PUT -H "Authorization: Bearer $TOKEN" \
         -H "Accept: application/vnd.github+json" \
         -H "X-GitHub-Api-Version: 2022-11-28" \
         "$API_URL" \
         -d "{
           \"message\": \"WOL logic: Processed all tasks\",
           \"content\": \"$new_encoded\",
           \"sha\": \"$sha\"
         }" > /dev/null
fi
