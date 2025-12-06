# Keenetic Route Manager

A unified bash script for managing custom routing rules on Keenetic routers. Route specific domain traffic through designated VPN interfaces with simple commands.

## Requirements

- `telnet` installed on your system
- `dig` (DNS lookup tool, part of dnsutils/bind-utils)
- `.env` file with router credentials
- Same local network as the target Keenetic router

## Setup

Create a `.env` file in the project root with your router credentials:

```bash
ROUTER_IP=<ip_of_the_router>
USERNAME=<username_of_the_router>
PASSWORD=<password_of_the_router>
```

**Note:** The `.env` file is git-ignored to protect your credentials.

## Usage

### Add Routes

Generate and apply routes to your router in one command:

```bash
./update_routes.sh <domain> <vpn_interface>
```

**What happens:**
1. Resolves the domain to IP addresses using DNS
2. Generates routing commands
3. Saves them to `_routes/<domain>_routes.txt`
4. Connects to the router via Telnet and applies the routes
5. Saves the router configuration

**Example:**
```bash
./update_routes.sh example.com Wireguard0
```

### Generate Routes Only

Generate the routes file without applying to the router:

```bash
./update_routes.sh <domain> <vpn_interface> --save-only
```

Useful when you want to review the routes before applying, or when you're not connected to the router's network.

### Remove Routes

Remove previously added routes:

```bash
./update_routes.sh <domain> --remove
```

**What happens:**
1. Reads the existing routes file `_routes/<domain>_routes.txt`
2. Connects to the router and removes each route using `no ip route ...` commands
3. Saves the router configuration

**Example:**
```bash
./update_routes.sh example.com --remove
```

## Examples

```bash
# Route Russian railway site through VPN
./update_routes.sh rzd.ru Wireguard0

# Generate routes for a mail server without applying
./update_routes.sh mail.rshu.ru Wireguard0 --save-only

# Remove routes for a domain
./update_routes.sh rzd.ru --remove
```

## How It Works

The script uses `dig` to resolve domain names to IP addresses, then generates Keenetic router commands. Each route directs traffic for specific IPs through your specified VPN interface.

**Generated route format:**
```
ip route 93.158.134.0 Wireguard0 auto !example.com
```

Routes are stored in `_routes/<domain>_routes.txt` for future reference and removal.

## KeeneticOS Version Compatibility

### KeeneticOS v4 (Current Support)

This script is designed for **KeeneticOS v4**, which does not support native domain-based routing. The script handles domain-to-IP resolution externally using `dig` and creates IP-based routes.

**How it works on v4:**
- DNS resolution happens on your local machine
- Only IPv4 addresses are sent to the router
- Routes are created as: `ip route <IP> <interface> auto`
- Manual route management via this script is required

### KeeneticOS v5.0+ (Future Support)

KeeneticOS v5.0 introduced native **DNS-Based Routing** using FQDN object groups:

**New features in v5:**
- Native domain-based routing via `dns-proxy route object-group` command
- Automatic DNS resolution by the router itself
- Dynamic IP updates when domains change
- No manual IP tracking needed

**Example v5 commands:**
```bash
object-group fqdn RUSSIAN_SITES include rzd.ru
dns-proxy route object-group RUSSIAN_SITES Wireguard0 auto
```

If you upgrade to KeeneticOS v5, this script will still work using the legacy IP-based routing method. Native v5 domain routing support may be added in future versions of this script.

**Check your router version:**
Connect via Telnet and check the banner - it shows `KeeneticOS version X.XX.X.X.X`

## Troubleshooting

**"Error: No IP addresses found for domain"**
- Check your DNS settings
- Verify the domain name is correct
- Try manually: `dig +short <domain>`

**"Error: Missing required environment variables"**
- Ensure `.env` file exists in the project root
- Verify it contains ROUTER_IP, USERNAME, and PASSWORD

**Telnet connection fails**
- Verify you're on the same network as the router
- Check if Telnet is enabled on your Keenetic router
- Confirm ROUTER_IP is correct

## License

MIT License - See LICENSE file for details
