#!/bin/bash

INTERFACE="any"
IP_FILTER=""
RESULTFILENAME="result.txt"
CAPTUREDDOMAINSFILE="domains.txt"
KEEP_DOMAINS_FILE=false

while getopts "i:t:r:d:k" opt; do
  case $opt in
    i) INTERFACE="$OPTARG" ;;
    t) IP_FILTER="host $OPTARG and" ;;
    r) RESULTFILENAME="$OPTARG" ;;
    d) CAPTUREDDOMAINSFILE="$OPTARG" ;;
    k) KEEP_DOMAINS_FILE=true ;;
    *) 
      echo "Usage: $0 [-i interface] [-t target_ip] [-r result_file] [-d domain_file] [-k]"
      exit 1
      ;;
  esac
done

echo "Process started. Capturing domain names on interface '$INTERFACE'..."
if [ -n "$IP_FILTER" ]; then
  echo "Capturing traffic for IP: $IP_FILTER"
else
  echo "Capturing traffic for all IPs."
fi
echo "Whenever you want to see the results, press any key."

sudo tcpdump -i "$INTERFACE" $IP_FILTER "port 80 or 443" -A > "$RESULTFILENAME" 2>/dev/null &

read -n 1 -s

kill $! 

awk '/^Host:/ { 
    if (gsub(/\./, "&", $2) == 1 || ($2 ~ /^www\./ && gsub(/\./, "&", $2) == 2)) 
        print $2 
}' "$RESULTFILENAME" | sort | uniq >> "$CAPTUREDDOMAINSFILE"

grep -oP 'www\.[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' "$RESULTFILENAME" | sort | uniq >> "$CAPTUREDDOMAINSFILE"

while read -r line; do
    dot_count=$(echo "$line" | awk -F'.' '{print NF-1}')
    
    if [ "$dot_count" -le 2 ]; then
        if [[ ! "$line" =~ ^www\. ]]; then
            line="www.$line"
        fi
        echo "$line"
    fi
done < "$CAPTUREDDOMAINSFILE" | sort | uniq

rm "$RESULTFILENAME"

if [ "$KEEP_DOMAINS_FILE" = false ]; then
  rm "$CAPTUREDDOMAINSFILE"
else

fi

echo "Results displayed. Script terminated."
