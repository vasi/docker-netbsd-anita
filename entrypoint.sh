#!/bin/sh
set -e

SSH_PORT=22
. /scripts/qemu-start.sh

if [ ! -z "$*" ]; then
  if [ -t 0 ]; then
    TTY="-t"
  fi
  ssh $TTY localhost $*
  # Shutdown after command finishes
  ssh localhost /sbin/poweroff >/dev/null 2>&1 || true
fi
wait
