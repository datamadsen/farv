#!/bin/bash

source /usr/share/farv/lib/utils.sh

if ! has_command tmux || ! tmux has-session 2>/dev/null; then
  echo "tmux is not running"
  exit 0
fi

tmux source-file ~/.tmux.conf
