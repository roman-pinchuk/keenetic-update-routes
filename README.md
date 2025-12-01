## Requirements

- `telnet` installed on your system
- `dig` (DNS lookup tool, part of dnsutils/bind-utils)
- `.env` file with router credentials
- Same local network as the target Keenetic router

## Setup

Create a `.env` file with the following:

```txt
ROUTER_IP=<ip_of_the_router>
USERNAME=<username_of_the_router>
PASSWORD=<password_of_the_router>
```

## Usage

Generate routes and apply them to your router in one command:

```bash
./update_routes.sh <your.awesome.domain> <vpn_interface>
```

This will:
1. Resolve the domain to IP addresses
2. Generate routing commands
3. Save them to `_routes/<your.awesome.domain>_routes.txt`
4. Apply the routes to your router via Telnet

### Generate Only (No Apply)

To only generate the routes file without applying to the router:

```bash
./update_routes.sh <your.awesome.domain> <vpn_interface> --save-only
```
