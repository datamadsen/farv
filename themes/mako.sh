#!/bin/bash

source /usr/share/farv/lib/utils.sh

if has_command makoctl && is_running mako; then
  makoctl reload
fi
