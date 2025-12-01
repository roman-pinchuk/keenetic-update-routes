#!/bin/bash

# Load environment variables from .env file if it exists
if [ -f .env ]; then
	export $(grep -v '^#' .env | xargs)
fi

# Parse arguments
REMOVE_MODE=false
SAVE_ONLY=false

# Check for flags
for arg in "$@"; do
	case $arg in
	--remove)
		REMOVE_MODE=true
		shift
		;;
	--save-only)
		SAVE_ONLY=true
		shift
		;;
	esac
done

# Check if domain name and VPN interface are provided
if [ -z "$1" ]; then
	echo "Usage: $0 <domain_name> [vpn_interface] [--save-only] [--remove]"
	echo ""
	echo "Options:"
	echo "  --save-only    Only generate routes file without applying to router"
	echo "  --remove       Remove routes from an existing routes file"
	echo ""
	echo "Examples:"
	echo "  Add routes:     $0 example.com Wireguard0"
	echo "  Remove routes:  $0 example.com --remove"
	exit 1
fi

DOMAIN=$1
VPN_INTERFACE=$2
OUTPUT_FILE="_routes/${DOMAIN}_routes.txt"

# Handle remove mode
if [ "$REMOVE_MODE" == true ]; then
	# Check if routes file exists
	if [ ! -f "$OUTPUT_FILE" ]; then
		echo "Error: Routes file not found: $OUTPUT_FILE"
		echo "Generate routes first before removing them."
		exit 1
	fi

	echo "==> Found routes file: $OUTPUT_FILE"
	echo "==> Preparing to remove $(wc -l <"$OUTPUT_FILE") route(s)"

	# Check if required variables are set for router connection
	if [ -z "$ROUTER_IP" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
		echo "Error: Missing required environment variables for router connection."
		echo "Ensure .env contains ROUTER_IP, USERNAME, and PASSWORD."
		exit 1
	fi

	echo "==> Connecting to router at $ROUTER_IP and removing routes..."

	# Function to generate Telnet commands for removing routes
	generate_telnet_remove_commands() {
		sleep 5
		echo "$USERNAME"
		sleep 3
		echo "$PASSWORD"
		sleep 1

		while IFS=' ' read -r ROUTE; do
			if [ -n "$ROUTE" ]; then
				# Prefix the route command with "no" to remove it
				echo "no $ROUTE"
				sleep 1
			fi
		done <"$OUTPUT_FILE"

		echo "system configuration save"
		sleep 1
		echo "exit"
	}

	# Execute Telnet session
	generate_telnet_remove_commands | telnet "$ROUTER_IP"

	echo "==> Done! Routes have been removed and configuration saved."
	exit 0
fi

# Add mode (default behavior)
# Check if VPN interface is provided for add mode
if [ -z "$VPN_INTERFACE" ]; then
	echo "Error: VPN interface is required when adding routes"
	echo "Usage: $0 <domain_name> <vpn_interface> [--save-only]"
	exit 1
fi

echo "==> Resolving domain: $DOMAIN"

# Resolve domain to IP addresses using dig
IP_ADDRESSES=$(dig +short "${DOMAIN}")

# Check if any IP addresses were found
if [ -z "$IP_ADDRESSES" ]; then
	echo "Error: No IP addresses found for domain: $DOMAIN"
	exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "_routes"

# Create the output file
>"$OUTPUT_FILE"

# Add routing commands to the file
for IP in $IP_ADDRESSES; do
	echo "ip route $IP $VPN_INTERFACE auto !$DOMAIN" >>"$OUTPUT_FILE"
done

echo "==> Generated $(wc -l <"$OUTPUT_FILE") route(s) and saved to $OUTPUT_FILE"

# If --save-only flag is set, exit here
if [ "$SAVE_ONLY" == true ]; then
	echo "==> Done (routes file saved, not applied to router)"
	exit 0
fi

# Check if required variables are set for router connection
if [ -z "$ROUTER_IP" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
	echo "Error: Missing required environment variables for router connection."
	echo "Ensure .env contains ROUTER_IP, USERNAME, and PASSWORD."
	echo ""
	echo "Routes file saved to: $OUTPUT_FILE"
	echo "You can apply it manually later."
	exit 1
fi

echo "==> Connecting to router at $ROUTER_IP and applying routes..."

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
		fi
	done <"$OUTPUT_FILE"

	echo "system configuration save"
	sleep 1
	echo "exit"
}

# Execute Telnet session
generate_telnet_commands | telnet "$ROUTER_IP"

echo "==> Done! Routes have been applied and configuration saved."
