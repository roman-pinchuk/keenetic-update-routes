#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
	export $(grep -v '^#' .env | xargs)
fi

# Check if required variables are set
if [ -z "$ROUTER_IP" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
	echo "Error: Missing required environment variables."
	echo "Ensure .env contains ROUTER_IP, USERNAME, and PASSWORD."
	exit 1
fi

# Check if the file path is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <path_to_routes_file>"
	exit 1
fi

ROUTES_FILE="$1"

# Function to generate Telnet commands for adding routes
generate_telnet_commands() {
	sleep 5
	echo "$USERNAME"
	sleep 3
	echo "$PASSWORD"
	sleep 1

	while IFS=' ' read -r ROUTE; do
		if [ -n "$ROUTE" ]; then
			echo "$ROUTE"
			sleep 1
		else
			echo "Invalid line: $ROUTE"
		fi
	done <"$ROUTES_FILE"

	echo "system configuration save"
	sleep 1
	echo "exit"
}

# Execute Telnet session
generate_telnet_commands | telnet "$ROUTER_IP"
