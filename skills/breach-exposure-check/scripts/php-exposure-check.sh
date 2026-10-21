#!/usr/bin/env bash
# php-exposure-check.sh: passive check for which sites you have accounts on run PHP.
#
# Makes ONE ordinary GET request to each site's homepage, like a browser visit,
# and reads only public signals: response headers, cookie names, and markers in the HTML.
# It does NOT probe for vulnerabilities, try exploits, or request admin/login paths.
#
# Usage:   ./php-exposure-check.sh domains.txt > results.tsv
# Input:   one domain per line (e.g. example.com)
# Output:  TSV: domain, status, verdict, php_version, evidence
#
# Verdicts: PHP-confirmed, PHP-likely, not-php(<platform>), no-php-signal,
#           dns-missing  (the name doesn't resolve: a candidate for "gone", confirm before saying so)
#           unreachable  (resolves but no answer: blocked, down, or a network hiccup; treat as unknown)

set -u
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0 Safari/537.36"
PARALLEL="${PARALLEL:-8}"

# Native Windows curl (e.g. under Git Bash) can't write to MSYS paths like /tmp. Hand it a Windows path.
winpath() { if command -v cygpath >/dev/null 2>&1; then cygpath -m "$1"; else printf '%s' "$1"; fi; }

check() {
  d="$1"
  tmp="$(mktemp -d)"; tw="$(winpath "$tmp")"
  code=$(curl -s -L --max-time 20 --max-redirs 5 -A "$UA" \
    -D "$tw/h" -o "$tw/b" -w '%{http_code}' "https://$d/" 2>/dev/null); rc=$?
  if [ ! -s "$tmp/h" ]; then
    [ "$rc" -eq 6 ] && v="dns-missing" || v="unreachable"
    printf '%s\t%s\t%s\t%s\t%s\n' "$d" "${code:-000}" "$v" "" "curl_exit:$rc"; rm -rf "$tmp"; return
  fi

  h=$(tr -d '\r' < "$tmp/h" | tr 'A-Z' 'a-z')
  b=$(head -c 600000 "$tmp/b" 2>/dev/null | tr -d '\000' | tr 'A-Z' 'a-z')
  ev=""; ver=""

  # Confirmed PHP signals
  xpb=$(printf '%s\n' "$h" | grep -m1 '^x-powered-by:' | cut -d' ' -f2-)
  if printf '%s' "$xpb" | grep -q 'php'; then
    ver=$(printf '%s' "$xpb" | grep -o 'php/[0-9][0-9.]*' | head -1 | cut -d/ -f2)
    ev="$ev x-powered-by:${xpb// /_}"
  fi
  printf '%s\n' "$h" | grep -q '^set-cookie: *phpsessid=' && ev="$ev cookie:PHPSESSID"
  printf '%s\n' "$h" | grep -q '^set-cookie: *laravel_session=' && ev="$ev cookie:laravel_session"
  printf '%s\n' "$h" | grep -q '^x-drupal-' && ev="$ev header:x-drupal"
  printf '%s\n' "$h" | grep -q '^x-magento-\|^set-cookie: *mage-' && ev="$ev magento"
  printf '%s\n' "$h" | grep -q '^link:.*wp-json' && ev="$ev header:wp-json"

  # Likely PHP: CMS/platform markers in the HTML
  printf '%s' "$b" | grep -q '/wp-content/\|/wp-includes/' && ev="$ev html:wordpress"
  printf '%s' "$b" | grep -q 'name="generator" content="wordpress\|content="wordpress' && ev="$ev generator:wordpress"
  printf '%s' "$b" | grep -q 'content="drupal\|/sites/default/files/' && ev="$ev html:drupal"
  printf '%s' "$b" | grep -q 'content="joomla' && ev="$ev html:joomla"
  printf '%s' "$b" | grep -q 'mage/cookies\|magento_' && ev="$ev html:magento"
  printf '%s' "$b" | grep -q 'woocommerce' && ev="$ev html:woocommerce"
  n=$(printf '%s' "$b" | grep -o 'href="[^"]*\.php[?"]' | wc -l | tr -d ' ')
  [ "${n:-0}" -gt 0 ] && ev="$ev html:.php_links($n)"

  # Not-PHP platform hints (for context)
  hint=""
  printf '%s\n' "$h" | grep -q '^x-shopify\|^server: *shopify\|shopify' && hint="shopify"
  printf '%s\n' "$h" | grep -q 'squarespace' && hint="squarespace"
  printf '%s\n' "$h" | grep -q '^x-vercel\|^server: *vercel' && hint="vercel"
  printf '%s\n' "$h" | grep -q '^x-nf-request-id\|^server: *netlify' && hint="netlify"
  printf '%s\n' "$h" | grep -q '^x-wix-' && hint="wix"
  printf '%s\n' "$h" | grep -q 'webflow' && hint="webflow"

  if printf '%s' "$ev" | grep -qi 'x-powered-by\|phpsessid\|laravel\|x-drupal\|magento'; then verdict="PHP-confirmed"
  elif [ -n "$ev" ]; then verdict="PHP-likely"
  elif [ -n "$hint" ]; then verdict="not-php($hint)"
  else verdict="no-php-signal"; fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$d" "$code" "$verdict" "$ver" "${ev# }"
  rm -rf "$tmp"
}
export -f check winpath
export UA

# Preflight: if a known-good site can't be fetched, every result would read "unreachable". Stop instead.
pre="$(mktemp -d)"
if ! curl -s --max-time 20 -A "$UA" -D "$(winpath "$pre")/h" -o /dev/null https://example.com/ 2>/dev/null || [ ! -s "$pre/h" ]; then
  echo "Preflight failed: couldn't fetch https://example.com/. Check your internet connection and curl, then rerun." >&2
  rm -rf "$pre"; exit 3
fi
rm -rf "$pre"

grep -v '^\s*$' "${1:-/dev/stdin}" | xargs -P "$PARALLEL" -I{} bash -c 'check "$@"' _ {}
