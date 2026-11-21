#!/usr/bin/env bash
# 16 KB page size check of a release build (plan §19.1 step 4). Google Play
# requires apps targeting Android 15+ (targetSdk 35+) to ship native
# libraries whose ELF LOAD segments are aligned to at least 16 KB (0x4000),
# so they load on 16 KB page devices.
#
# Usage: tools/ci/check-16kb-alignment.sh <app.aab|app.apk>
# Needs unzip and readelf (binutils or the NDK's llvm-readelf).
# Exit codes: 0 every arm64-v8a/x86_64 library aligned, 1 a library is not,
# 2 bad input or missing tools.
set -euo pipefail

archive="${1:?usage: $0 <app.aab|app.apk>}"
[[ -f "$archive" ]] || { echo "error: no such file: $archive" >&2; exit 2; }

readelf_bin="$(command -v llvm-readelf || command -v readelf || true)"
[[ -n "$readelf_bin" ]] || { echo "error: readelf not found (install binutils)" >&2; exit 2; }
command -v unzip >/dev/null || { echo "error: unzip not found" >&2; exit 2; }

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
# AAB: base/lib/<abi>/*.so; APK: lib/<abi>/*.so. Only 64-bit ABIs have
# 16 KB page devices. Entries are listed and extracted by exact name: some
# unzip builds (MSYS) do not match wildcards.
mapfile -t libs < <(unzip -Z1 "$archive" | grep -E '^(base/)?lib/(arm64-v8a|x86_64)/[^/]+\.so$' || true)
if ((${#libs[@]} > 0)); then
  unzip -q -o "$archive" "${libs[@]}" -d "$work"
fi

status=0
count=0
while IFS= read -r -d '' so; do
  count=$((count + 1))
  rel="${so#"$work"/}"
  # Smallest alignment of the LOAD program headers (last column, hex).
  min="$("$readelf_bin" -lW "$so" | awk '$1 == "LOAD" { print $NF }' \
    | while read -r a; do printf '%d\n' "$a"; done | sort -n | head -n1)"
  if [[ -z "$min" ]]; then
    echo "?? $rel: no LOAD segments"
    status=1
  elif ((min < 16384)); then
    printf 'FAIL %s: LOAD alignment %d (< 16384)\n' "$rel" "$min"
    status=1
  else
    printf 'ok   %s: LOAD alignment %d\n' "$rel" "$min"
  fi
done < <(find "$work" -name '*.so' -print0 | sort -z)

if ((count == 0)); then
  echo "No 64-bit native libraries in $archive (nothing to check)."
elif ((status == 0)); then
  echo "All $count native libraries are 16 KB page aligned."
else
  echo "::error::Native libraries not aligned to 16 KB pages (Play rejects them for targetSdk 35+)."
fi
exit $status
