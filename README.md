For using `update_routes_by_telnet.sh`, you must have `telnet` and `.env` and be in the same local network as the target Keenetic router.

`.env` should include the following:

```txt
ROUTER_IP=<ip_of_the_router>
USERNAME=<username_of_the_router>
PASSWORD=<password_of_the_router>
```

To generate commands for routing, run as following:

```nix
./generate_routes.sh <your.awesome.domain> <vpn_interface>
```

And you will get `_routes/<your.awesome.domain>_routes.txt`

For upgrade the routes by the generated file:

```nix
./update_routes_by_telnet.sh _routes/<your.awesome.domain>_routes.txt
```
