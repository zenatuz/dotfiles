#!/bin/bash
#
# Colima auto-stop — para a VM após inatividade prolongada (sem containers).
# Acionado pelo LaunchAgent ~/Library/LaunchAgents/com.user.colima-autostop.plist
# a cada 5 min. Só desliga após 3 checks consecutivos sem containers (≈15 min).

STATE_DIR="$HOME/.local/state/colima"
STATE_FILE="$STATE_DIR/colima-idle"
LOG_FILE="$STATE_DIR/autostop.log"
INTERVAL_SEC=300
MAX_IDLE_SEC=$((INTERVAL_SEC * 3))

mkdir -p "$STATE_DIR"

{
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] check"

  colima status &>/dev/null || { echo "  colima not running, skip"; exit 0; }

  RUNNING=$(/opt/homebrew/bin/docker ps -q 2>/dev/null)

  if [ -n "$RUNNING" ]; then
    echo "  containers running, reset idle timer"
    rm -f "$STATE_FILE"
    exit 0
  fi

  NOW=$(date +%s)
  if [ -f "$STATE_FILE" ]; then
    IDLE_SINCE=$(cat "$STATE_FILE")
    IDLE_TIME=$((NOW - IDLE_SINCE))
    echo "  idle for ${IDLE_TIME}s (max ${MAX_IDLE_SEC}s)"

    if [ "$IDLE_TIME" -ge "$MAX_IDLE_SEC" ]; then
      echo "  stopping colima..."
      colima stop
      rm -f "$STATE_FILE"
    fi
  else
    echo "  no containers, marking idle start"
    echo "$NOW" > "$STATE_FILE"
  fi
} >> "$LOG_FILE" 2>&1
