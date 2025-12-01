# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Keenetic router route management tool that generates and applies custom routing rules via Telnet. The system allows routing specific domain traffic through designated VPN interfaces on Keenetic routers.

**Use case:** Route traffic for specific domains (e.g., region-locked services) through a VPN interface while keeping other traffic on the default route.

## Architecture

The project consists of a single unified bash script (`update_routes.sh`) with two operational modes:

### Add Mode (default)
1. **DNS Resolution** - Uses `dig +short` to resolve domain to IP addresses
2. **Route Generation** - Creates Keenetic router commands in format: `ip route <IP> <VPN_INTERFACE> auto !<DOMAIN>`
3. **File Persistence** - Saves commands to `_routes/<domain>_routes.txt` for future removal
4. **Route Application** - Applies commands to router via Telnet
   - Loads credentials from `.env` file (ROUTER_IP, USERNAME, PASSWORD)
   - Uses timed `sleep` commands to handle Telnet session flow
   - Executes each route command sequentially with 1-second delays
   - Saves configuration with `system configuration save` before exiting

### Remove Mode
When using `--remove` flag:
1. **File Validation** - Checks if routes file exists for the specified domain
2. **Route Removal** - Reads existing routes and prefixes with `no` command
3. **Router Application** - Connects via Telnet and executes `no ip route ...` commands
4. **Configuration Save** - Persists changes to router configuration

### Flags
- `--save-only` - Generate routes file without applying to router (add mode only)
- `--remove` - Remove routes using existing routes file

## Key Dependencies

- `dig` - DNS lookup tool (part of dnsutils/bind-utils package)
- `telnet` - Telnet client for router communication (must be installed separately on most systems)
- Local network access to the Keenetic router (cannot be used remotely)

## Environment Configuration

The `.env` file must contain:
```bash
ROUTER_IP=<router_ip_or_hostname>
USERNAME=<router_admin_username>
PASSWORD=<router_admin_password>
```

**Important:** `.env` is git-ignored and contains sensitive credentials. Never commit this file.

## Common Commands

Add routes (resolve, generate, and apply):
```bash
./update_routes.sh <domain_name> <vpn_interface>
```

Generate routes without applying (dry-run):
```bash
./update_routes.sh <domain_name> <vpn_interface> --save-only
```

Remove previously added routes:
```bash
./update_routes.sh <domain_name> --remove
```

## Usage Examples

```bash
# Route Russian railway site through Wireguard VPN
./update_routes.sh rzd.ru Wireguard0

# Generate routes for testing without applying
./update_routes.sh mail.rshu.ru Wireguard0 --save-only

# Remove routes when no longer needed
./update_routes.sh rzd.ru --remove

# Multiple domains can be managed independently
./update_routes.sh blog.rt.ru Wireguard0
./update_routes.sh spb.rt.ru Wireguard0
```

## Output Directory Structure

```
_routes/
├── example.com_routes.txt
├── rzd.ru_routes.txt
└── blog.rt.ru_routes.txt
```

- `_routes/` - Contains generated route files in `.txt` format
- Each file contains Keenetic CLI commands (one per line)
- Files are named `<domain>_routes.txt`
- These files are reused by the `--remove` command

## Keenetic Router Command Format

### Adding a route:
```
ip route <IP_ADDRESS> <VPN_INTERFACE> auto !<DOMAIN>
```

### Removing a route:
```
no ip route <IP_ADDRESS> <VPN_INTERFACE> auto !<DOMAIN>
```

**Parameters:**
- `<IP_ADDRESS>` - Resolved IP from DNS lookup
- `<VPN_INTERFACE>` - Target VPN interface name (e.g., Wireguard0, Wireguard1, OpenVPN0)
- `!<DOMAIN>` - Comment/description with the original domain

## Implementation Notes

- The script uses argument parsing with a loop to handle flags like `--remove` and `--save-only`
- Telnet session flow is controlled by `sleep` commands (5s initial, 3s for username, 1s between commands)
- DNS resolution can return multiple IPs for a single domain, resulting in multiple routes
- VPN interface parameter is optional only when using `--remove` (not needed since routes file contains the interface)
- Routes file serves as both documentation and removal mechanism

## Error Handling

The script validates:
- Required arguments are provided
- DNS resolution succeeds (at least one IP found)
- Routes file exists before removal attempt
- Environment variables are set before connecting to router
- VPN interface is provided when adding routes

## Testing Approach

When testing changes:
1. Use `--save-only` flag first to verify route generation
2. Check generated files in `_routes/` directory
3. Apply routes to router only after verification
4. Test removal functionality on non-critical routes first
