source /usr/share/farv/lib/utils.sh

if has_command "claude"; then
  claude config set -g theme light
fi
