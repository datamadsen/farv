#!/bin/bash

source /usr/share/farv/lib/utils.sh

if has_command swaync-client && is_running swaync; then
  swaync-client -rs
fi
