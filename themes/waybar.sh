#!/bin/bash

source /usr/share/farv/lib/utils.sh

if has_command waybar && is_running waybar; then
  killall -SIGUSR2 waybar
fi
