#!/bin/sh
# Checks that the four manifests and the two MCP files agree.
# Needs python3 for JSON parsing. Run from anywhere: sh scripts/check.sh
set -eu
cd "$(dirname "$0")/.."

fail=0
err() { echo "FAIL: $*" >&2; fail=1; }

MANIFESTS=".cursor-plugin/plugin.json .grok-plugin/plugin.json .claude-plugin/plugin.json .codex-plugin/plugin.json"

# 1. Every JSON file parses.
for f in $MANIFESTS mcp.json .mcp.json; do
  if [ ! -f "$f" ]; then err "$f is missing"; continue; fi
  python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$f" 2>/dev/null || err "$f is not valid JSON"
done

# 2. The two MCP files are the same, byte for byte.
if [ -f mcp.json ] && [ -f .mcp.json ]; then
  cmp -s mcp.json .mcp.json || err "mcp.json and .mcp.json differ"
fi

# 3. One version and one name in all four manifests.
versions=""
for f in $MANIFESTS; do
  [ -f "$f" ] || continue
  v=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("version",""))' "$f" 2>/dev/null || echo "")
  n=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1])).get("name",""))' "$f" 2>/dev/null || echo "")
  [ -n "$v" ] || err "$f has no version"
  [ "$n" = "0tx" ] || err "$f has name '$n', expected '0tx'"
  echo "$f: version $v"
  versions="$versions $v"
done
count=$(printf '%s\n' $versions | sort -u | wc -l | tr -d ' ')
[ "$count" = "1" ] || err "manifest versions differ:$versions"

# 4. The server address is the one the resource metadata names.
url=$(python3 -c 'import json; print(json.load(open("mcp.json"))["mcpServers"]["0tx"]["url"])' 2>/dev/null || echo "")
[ "$url" = "https://api.0tx.app/mcp" ] || err "mcp.json points at '$url', expected https://api.0tx.app/mcp"

# 5. The old address appears nowhere (this script spells it in two parts).
old="https://0tx.app""/mcp"
hits=$(grep -rnF --exclude-dir=.git --exclude-dir=dist --exclude-dir=node_modules -e "$old" . || true)
if [ -n "$hits" ]; then
  err "the old address $old appears in:"
  echo "$hits" >&2
fi

# 6. Each skill has a name that matches its folder, and a description.
for d in skills/*/; do
  s="${d}SKILL.md"
  name=$(basename "$d")
  [ -f "$s" ] || { err "$s is missing"; continue; }
  [ "$(sed -n '1p' "$s")" = "---" ] || err "$s does not start with frontmatter"
  grep -q "^name: $name\$" "$s" || err "$s: frontmatter name is not '$name'"
  grep -q '^description: .' "$s" || err "$s: no description"
done

if [ "$fail" -ne 0 ]; then
  echo "check failed" >&2
  exit 1
fi
echo "check passed"
