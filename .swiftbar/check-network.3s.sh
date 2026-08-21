#!/usr/bin/env bash
# <xbar.title>Check Network</xbar.title>
# <xbar.desc>Monitors default gateway, internet, and DNS connectivity with icon-based status in the menu bar</xbar.desc>
# <xbar.author>zenatuz</xbar.author>
# <xbar.version>v1.1</xbar.version>
# <xbar.dependencies>bash, ping, route</xbar.dependencies>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideDisablePlugin>true</swiftbar.hideDisablePlugin>
# <swiftbar.hideSwiftBar>false</swiftbar.hideSwiftBar>
# <swiftbar.refreshOnOpen>false</swiftbar.refreshOnOpen>

# ── Network Connectivity Monitor ──
# Tests: default gateway + DNS resolution
# Icons: 🌐 online | ⚠️ DNS issue | ⛔ no network

PING_COUNT=2
PING_TIMEOUT=3

# ── Detect default gateway dynamically ──
detect_gateway() {
  route -n get default 2>/dev/null | awk '/gateway:/ {print $2}'
}

# ── Detect active interface name ──
detect_interface() {
  route -n get default 2>/dev/null | awk '/interface:/ {print $2}'
}

# ── Ping helper: returns avg latency in ms, or empty on failure ──
ping_latency() {
  local host="$1"
  local out
  out=$(ping -c "$PING_COUNT" -W "$PING_TIMEOUT" -q "$host" 2>&1)
  local rc=$?
  if [ $rc -eq 0 ]; then
    echo "$out" | tail -1 | sed -n 's/.*= [0-9.]*\/\([0-9.]*\).*/\1/p'
  fi
}

# ── Detect default gateway ──
GATEWAY=$(detect_gateway)
INTERFACE=$(detect_interface)

# No network at all
if [ -z "$GATEWAY" ]; then
  echo "⛔"
  echo "---"
  echo "Status: No Network"
  echo "No active default gateway found."
  echo "---"
  echo "Last check: $(date '+%H:%M:%S')|size=10"
  exit 0
fi

INTERNET_HOST="1.1.1.1"
DNS_HOST="one.one.one.one"

# ── Tests ──
GW_LATENCY=$(ping_latency "$GATEWAY")
GW_OK=$([ -n "$GW_LATENCY" ] && echo "true" || echo "false")

NET_LATENCY=$(ping_latency "$INTERNET_HOST")
NET_OK=$([ -n "$NET_LATENCY" ] && echo "true" || echo "false")

# DNS: ping hostname (requires actual DNS resolution)
DNS_LATENCY=$(ping_latency "$DNS_HOST")
DNS_OK=$([ -n "$DNS_LATENCY" ] && echo "true" || echo "false")

# ── Status logic ──
STATUS=""
ICON=""
if [ "$GW_OK" = "false" ]; then
  STATUS="No Network"
  ICON="⛔"
elif [ "$DNS_OK" = "false" ]; then
  STATUS="DNS Issue"
  ICON="⚠️"
else
  STATUS="Online"
  ICON="🌐"
fi

# ── Menu bar icon ──
echo "$ICON"

# ── Dropdown menu ──
echo "---"
echo "Status: $STATUS"
echo "---"
echo "Gateway: $GATEWAY ($INTERFACE)"
if [ "$GW_OK" = "true" ]; then
  echo "  ✅ ${GW_LATENCY}ms"
else
  echo "  ❌ unreachable|color=red"
fi
echo "Internet: $INTERNET_HOST"
if [ "$NET_OK" = "true" ]; then
  echo "  ✅ ${NET_LATENCY}ms"
else
  echo "  ❌ unreachable|color=red"
fi
echo "DNS: $DNS_HOST"
if [ "$DNS_OK" = "true" ]; then
  echo "  ✅ ${DNS_LATENCY}ms"
else
  echo "  ❌ failed|color=red"
fi
echo "---"
echo "Last check: $(date '+%H:%M:%S')|size=10"
