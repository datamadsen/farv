#!/bin/bash

source /usr/share/farv/lib/utils.sh

if ! has_command hyprctl; then
  exit 0
fi

hyprctl reload >/dev/null 2>&1
