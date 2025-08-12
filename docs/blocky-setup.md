# Blocky DNS Setup Guide

## Overview

Blocky is now configured on `callisto` to provide network-wide DNS filtering and ad-blocking for the chateaubr.ink network.

## Configuration

### Enabled Features
- **DNS Proxy**: Handles all DNS queries for the network
- **Ad Blocking**: Blocks ads, malware, and tracking domains
- **DNS Caching**: Improves response times with 5-30 minute cache
- **Custom DNS**: Local domain resolution for *.chateaubr.ink
- **Metrics**: Prometheus metrics available for monitoring

### Upstream DNS Servers
- Primary: Cloudflare DoH (https://one.one.one.one/dns-query)
- Secondary: Google DoH (https://dns.google/dns-query)

### Local Domain Mappings
- `callisto.chateaubr.ink` → `192.168.11.10`
- `ganymede.chateaubr.ink` → `192.168.11.11`
- `frame.chateaubr.ink` → `192.168.11.12`
- `macme.chateaubr.ink` → `192.168.11.13`

## Deployment

### 1. Build and Deploy
```bash
cd bigbang
nrr callisto
```

### 2. Configure Network DNS
After deployment, update your router or DHCP settings to use callisto as the DNS server:
- Primary DNS: `192.168.1.10` (callisto's IP)
- Secondary DNS: `192.168.1.1` (fallback to router)

### 3. Test DNS Resolution
```bash
# Test basic DNS
nslookup google.com 192.168.1.10

# Test local domain resolution
nslookup ganymede.chateaubr.ink 192.168.1.10

# Test ad blocking (should return NXDOMAIN or 0.0.0.0)
nslookup doubleclick.net 192.168.1.10
```

## Monitoring

### Web Interface
- **Admin Interface**: https://dns.rgbr.ink
- **Metrics**: https://dns.rgbr.ink/metrics

### Key Metrics
- Query count and types
- Blocked queries percentage
- Cache hit ratio
- Response times
- Upstream health

## Block Lists

### Default Categories
- **ads**: General advertising domains
- **malware**: Known malicious domains
- **tracking**: Analytics and tracking domains

### Sources
- StevenBlack's hosts file (comprehensive)
- AdGuard filters
- Malware domain blocklist
- WindowsSpyBlocker tracking list

## Customization

### Adding Custom Block Lists
Edit `bigbang/hosts/callisto/configuration.nix`:

```nix
host.blocky.blocking.lists = {
  ads = [ /* existing lists */ ];
  social = [
    "https://blocklistproject.github.io/Lists/facebook.txt"
    "https://blocklistproject.github.io/Lists/twitter.txt"
  ];
};
```

### Client-Specific Blocking
Configure different block levels per device:

```nix
host.blocky.blocking.clientGroups = {
  default = ["ads" "malware"];
  kids = ["ads" "malware" "social"];
  work = ["ads" "malware" "tracking"];
};
```

### Whitelisting Domains
Add domains to bypass blocking:

```nix
services.blocky.settings.blocking.whiteLists.allowlist = [
  "example.com"
  "trusted-domain.net"
];
```

## Troubleshooting

### Check Blocky Status
```bash
systemctl status blocky
journalctl -u blocky -f
```

### Test DNS Queries
```bash
# Query directly through Blocky
dig @192.168.1.10 example.com

# Check if domain is blocked
dig @192.168.1.10 doubleclick.net
```

### Common Issues

1. **DNS not resolving**: Check firewall and service status
2. **Local domains not working**: Verify IP mappings in configuration
3. **Too aggressive blocking**: Review block lists and add whitelists
4. **Slow responses**: Check upstream DNS health and caching settings

## Security

### Firewall Rules
- Port 53 (TCP/UDP): DNS queries
- Port 4000 (TCP): Metrics endpoint (internal only)

### Hardening
The service runs with restricted permissions:
- Private tmp directory
- Read-only system
- No new privileges
- Memory write protection

## Integration with LGTM Stack

Blocky metrics are automatically collected by the monitoring stack:
- **Grafana**: DNS query dashboards
- **Loki**: DNS query logs
- **Mimir**: Long-term metrics storage

Access dashboards at https://metrics.rgbr.ink
