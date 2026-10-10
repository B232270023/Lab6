#!/usr/bin/env bash
set -euo pipefail

# Build PICT outside this repository first, as required by the lab.
PICT_SRC="${PICT_SRC:-$HOME/tools/pict}"
PICT_BIN="${PICT_BIN:-$PICT_SRC/build/cli/pict}"

if [[ ! -x "$PICT_BIN" ]]; then
  printf 'PICT executable not found or not executable: %s\n' "$PICT_BIN" >&2
  printf 'Build the official source outside this repository, or set PICT_BIN.\n' >&2
  exit 1
fi
if [[ ! -d "$PICT_SRC/.git" ]]; then
  printf 'PICT source Git checkout not found: %s\n' "$PICT_SRC" >&2
  exit 1
fi

mkdir -p results
{
  git -C "$PICT_SRC" log -1 --format='pict commit %h %ad' --date=short
  { "$PICT_BIN" 2>&1 || true; } | head -3
} > results/pict-build.txt

"$PICT_BIN" browser.model > results/browser-2way.txt
"$PICT_BIN" browser.model /o:3 > results/browser-3way.txt
"$PICT_BIN" transfer-nc.model > results/transfer-nc.txt
"$PICT_BIN" transfer.model > results/transfer.txt
"$PICT_BIN" transfer-neg.model > results/transfer-neg.txt

printf 'Output data rows (header excluded):\n'
for output in results/browser-2way.txt results/browser-3way.txt \
              results/transfer-nc.txt results/transfer.txt results/transfer-neg.txt; do
  printf '%-32s %s\n' "$output" "$(tail -n +2 "$output" | wc -l)"
done
