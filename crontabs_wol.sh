#!/bin/sh

source_url="https://raw.githubusercontent.com/Mowei/wol/main/list"
content=$(curl -k -s $source_url)

if [ -n "$content" ]; then
  date=$(echo $content | cut -d',' -f1)
  mac=$(echo $content | cut -d',' -f2)
  if [ "$date" == "$(date +%Y/%m/%d)" ]; then
    curl -k -X GET "https://127.0.0.1:8443/wol_action.asp?dstmac=$mac"
  fi
fi
EOF
