#!/bin/sh

source_url="https://raw.githubusercontent.com/Mowei/wol/main/list"
content=$(curl -k -s $source_url)

if [ -n "$content" ]; then
  IFS=',' read -r date mac <<< "$content"
  if [ "$date" == "$(date +%Y/%m/%d)" ]; then
    curl -k -X GET "https://127.0.0.1:8443/wol_action.asp?dstmac=$mac"
  fi
fi
EOF
