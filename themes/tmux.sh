#!/bin/bash

source /usr/share/farv/lib/utils.sh

if ! has_command tmux || ! is_running tmux; then
  exit 0
fi

tmux source-file ~/.tmux.conf 2>/dev/null
