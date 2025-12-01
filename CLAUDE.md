# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Keenetic router route management tool that generates and applies custom routing rules via Telnet. The system allows routing specific domain traffic through designated VPN interfaces on Keenetic routers.

## Architecture

The project consists of a unified bash script (`update_routes.sh`) that handles the complete workflow:

1. **DNS Resolution** - Resolves domain to IP addresses using `dig`
2. **Route Generation** - Creates Keenetic router commands in format: `ip route <IP> <VPN_INTERFACE> auto !<DOMAIN>`
3. **Route Application** - Applies commands to router via Telnet
   - Loads credentials from `.env` file (ROUTER_IP, USERNAME, PASSWORD)
   - Uses timed `sleep` commands to handle Telnet session flow
   - Executes each route command sequentially with 1-second delays
   - Saves configuration with `system configuration save` before exiting

The script supports a `--save-only` flag to generate routes without applying them.

## Key Dependencies

- `dig` - DNS lookup tool (part of dnsutils/bind-utils)
- `telnet` - Telnet client for router communication
- Local network access to the Keenetic router

## Environment Configuration

The `.env` file must contain:
```
ROUTER_IP=<router_ip_or_hostname>
USERNAME=<router_admin_username>
PASSWORD=<router_admin_password>
```

Note: `.env` is git-ignored and contains sensitive credentials.

## Common Commands

Generate and apply routes in one command:
```bash
./update_routes.sh <domain_name> <vpn_interface>
```

Generate routes without applying (save only):
```bash
./update_routes.sh <domain_name> <vpn_interface> --save-only
```

Example:
```bash
./update_routes.sh example.com Wireguard0
```

## Output Directory

- `_routes/` - Contains generated route files in `.txt` format
- Each file contains Keenetic CLI commands (one per line)
- Files are named `<domain>_routes.txt`

## Keenetic Router Command Format

Route commands follow this pattern:
```
ip route <IP_ADDRESS> <VPN_INTERFACE> auto !<DOMAIN>
```

Where:
- `<IP_ADDRESS>` - Resolved IP from DNS lookup
- `<VPN_INTERFACE>` - Target VPN interface name (e.g., Wireguard0)
- `!<DOMAIN>` - Comment/description with the original domain
