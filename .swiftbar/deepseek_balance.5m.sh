#!/bin/bash

# <swiftbar.title>DeepSeek Balance</swiftbar.title>
# <swiftbar.version>v1.0</swiftbar.version>
# <swiftbar.author>Antigravity</swiftbar.author>
# <swiftbar.desc>Checks DeepSeek API balance with toggle.</swiftbar.desc>
# <swiftbar.image>https://raw.githubusercontent.com/deepseek-ai/deepseek-ai.github.io/main/favicon.ico</swiftbar.image>

# ==============================================================================
# CONFIGURATION
# ==============================================================================
# Load credentials from .env (see .env.example)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$SCRIPT_DIR/.env" ] && source "$SCRIPT_DIR/.env"
API_KEY="${DEEPSEEK_API_KEY:-}"

# File to store the state (On/Off)
STATE_FILE="$HOME/.deepseek_swiftbar_status"
# ==============================================================================

# Initialize state if it doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "ON" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

# Handle toggle
if [ "$1" == "toggle" ]; then
    if [ "$CURRENT_STATE" == "ON" ]; then
        echo "OFF" > "$STATE_FILE"
    else
        echo "ON" > "$STATE_FILE"
    fi
    # Refresh SwiftBar immediately
    exit 0
fi

# Interface when disabled
if [ "$CURRENT_STATE" == "OFF" ]; then
    echo "DS: ⏸️ | symbol=pause.circle color=gray"
    echo "---"
    echo "Status: Monitoring Paused | color=gray"
    echo "Enable Monitoring | symbol=play.circle bash='$0' param1=toggle refresh=true"
    exit 0
fi

# Query balance if enabled
RESPONSE=$(curl -s -L -X GET 'https://api.deepseek.com/user/balance' \
    -H 'Accept: application/json' \
    -H "Authorization: Bearer $API_KEY")

# Check if the response contains balance data
if [[ $RESPONSE == *"balance_infos"* ]]; then
    # Extract values using grep/sed (to avoid depending on jq)
    BALANCE=$(echo "$RESPONSE" | grep -o '"total_balance":"[^"]*"' | head -1 | cut -d'"' -f4)
    CURRENCY=$(echo "$RESPONSE" | grep -o '"currency":"[^"]*"' | head -1 | cut -d'"' -f4)

    # Menu bar title with whale icon and integer value
    BALANCE_INT=${BALANCE%.*}
    echo "🐋 $BALANCE_INT | color=green"
    echo "---"
    echo "DeepSeek API Balance | size=14"

    # Menu details with icons
    echo "$RESPONSE" | grep -o '"topped_up_balance":"[^"]*"' | sed 's/"topped_up_balance":"/Top-up: /;s/"//' | awk '{print $0 " | symbol=creditcard"}'
    echo "$RESPONSE" | grep -o '"granted_balance":"[^"]*"' | sed 's/"granted_balance":"/Granted: /;s/"//' | awk '{print $0 " | symbol=gift"}'

    echo "---"
    echo "Refresh now | symbol=arrow.clockwise refresh=true"
    echo "Disable Monitoring | symbol=pause.circle bash='$0' param1=toggle refresh=true"
else
    echo "DS: ⚠️ Error | symbol=exclamationmark.triangle color=red"
    echo "---"
    echo "Error fetching balance"
    if [[ -z "$API_KEY" || $API_KEY == "PASTE_YOUR_API_KEY_HERE" ]]; then
        echo "⚠️ Set your API Key in .env | color=orange"
    else
        echo "Response: $RESPONSE"
    fi
    echo "---"
    echo "Retry | symbol=arrow.clockwise refresh=true"
    echo "Disable Monitoring | symbol=pause.circle bash='$0' param1=toggle refresh=true"
fi
