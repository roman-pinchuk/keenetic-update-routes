#!/bin/bash

# Check if a domain name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <domain_name>"
    exit 1
fi

DOMAIN=$1
OUTPUT_FILE="_routes/${DOMAIN}_routes.txt"
VPN_INTERFACE="Wireguard0" # Replace with your VPN interface name if different

# Resolve domain to IP addresses using dig
IP_ADDRESSES=$(dig +short "${DOMAIN}")

# Check if any IP addresses were found
if [ -z "$IP_ADDRESSES" ]; then
    echo "No IP addresses found for domain: $DOMAIN"
    exit 1
fi

# Create the output file
touch "$OUTPUT_FILE"

# Add routing commands to the file
for IP in $IP_ADDRESSES; do
    echo "ip route $IP $VPN_INTERFACE auto !$DOMAIN" >>"$OUTPUT_FILE"
done

echo "Routing commands have been saved to $OUTPUT_FILE"
