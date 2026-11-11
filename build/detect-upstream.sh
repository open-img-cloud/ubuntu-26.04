#!/usr/bin/env bash
# Prints the latest upstream Ubuntu 26.04 LTS cloud image version on stdout.
#
# Parses the directory listing at
#   https://cloud-images.ubuntu.com/releases/resolute/
# for dated build directories and prints <26.04>-<build id> for the highest
# one (e.g. 26.04-20261016). Runs in the upstream-watch reusable workflow
# (no KVM needed): keep it portable bash + curl + grep + sort only.

set -euo pipefail

URL='https://cloud-images.ubuntu.com/releases/resolute/'

listing=$(curl -fsL "$URL")
if [[ -z "$listing" ]]; then
  echo "::error::could not fetch $URL" >&2
  exit 1
fi

latest=$(printf '%s\n' "$listing" \
  | grep -oE 'release-[0-9]{8}(\.[0-9]+)?/' \
  | sed -E 's#release-([0-9]{8}(\.[0-9]+)?)/#\1#' \
  | sort -uV \
  | tail -n1)

if [[ -z "$latest" ]]; then
  echo "::error::no build directory found in $URL" >&2
  exit 1
fi

printf '26.04-%s\n' "$latest"
