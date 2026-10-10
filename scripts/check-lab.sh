#!/usr/bin/env bash
set -u

failures=0
require_file() {
  if [[ ! -s "$1" ]]; then
    printf 'FAIL missing/empty: %s\n' "$1"
    failures=$((failures + 1))
  else
    printf 'OK   %s\n' "$1"
  fi
}

for file in README.md .gitignore browser.model transfer-nc.model \
            transfer.model transfer-neg.model scripts/run-pict.sh \
            results/pict-build.txt results/browser-2way.txt \
            results/browser-3way.txt results/transfer-nc.txt \
            results/transfer.txt results/transfer-neg.txt; do
  require_file "$file"
done

check_rows() {
  file=$1 expected=$2
  actual=$(tail -n +2 "$file" | wc -l | tr -d ' ')
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL %s has %s data rows; README expects %s\n' "$file" "$actual" "$expected"
    failures=$((failures + 1))
  else
    printf 'OK   %s: %s data rows\n' "$file" "$actual"
  fi
}

check_rows results/browser-2way.txt 10
check_rows results/browser-3way.txt 20
check_rows results/transfer-nc.txt 13
check_rows results/transfer.txt 15
check_rows results/transfer-neg.txt 16

a3_count=$(grep -Ec '^\|[[:space:]]*[0-9]+[[:space:]]*\|' README.md || true)
if (( a3_count < 10 )); then
  printf 'FAIL README has only %s numbered specification rows\n' "$a3_count"
  failures=$((failures + 1))
else
  printf 'OK   README has %s numbered specification rows\n' "$a3_count"
fi

negative_stats=$(awk -F '\t' 'NR > 1 {n=0; valid=1; for(i=1;i<=NF;i++) if($i ~ /^~/) n++; if(n>1) bad++; if(n==0 && $1=="Valid" && $2=="Valid" && $3=="Normal") happy++; if(n==1) single++} END {printf "%d %d %d", happy, single, bad}' results/transfer-neg.txt)
read -r happy_rows single_negative_rows multi_negative_rows <<< "$negative_stats"
printf 'PICT-neg audit: %s happy paths, %s one-error rows, %s rows with multiple negatives\n' \
  "$happy_rows" "$single_negative_rows" "$multi_negative_rows"
if [[ "$happy_rows" != 2 || "$single_negative_rows" != 14 || "$multi_negative_rows" != 0 ]]; then
  printf 'FAIL PICT-neg output does not match README analysis\n'
  failures=$((failures + 1))
fi

if grep -qi 'Source build attempt: blocked' results/pict-build.txt; then
  printf 'BLOCKED source-build criterion: results/pict-build.txt records that source compilation did not complete\n'
  failures=$((failures + 1))
else
  printf 'OK   source-build evidence present; confirm it came from the compiled local binary\n'
fi

if git rev-list --count HEAD | grep -qx '5'; then
  printf 'OK   exactly five Git commits\n'
else
  printf 'FAIL repository currently has %s Git commits; requested total is five\n' "$(git rev-list --count HEAD)"
  failures=$((failures + 1))
fi

if (( failures > 0 )); then
  printf 'AUDIT FAILED: %s issue(s) need attention\n' "$failures"
  exit 1
fi
printf 'AUDIT PASSED\n'
