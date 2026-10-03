#!/bin/sh
# Writes dist/0tx-openai-plugin.zip for upload at platform.openai.com/plugins.
# The archive holds the .codex-plugin manifest, .mcp.json, skills/ and the
# assets the manifest names. Nothing else is included.
set -eu
cd "$(dirname "$0")/.."

sh scripts/check.sh >/dev/null

out="dist/0tx-openai-plugin.zip"
mkdir -p dist
rm -f "$out"

# Fixed file list, sorted, without extra attributes, so two builds of the
# same commit list the same files.
{
  echo .codex-plugin/plugin.json
  echo .mcp.json
  echo assets/logo.png
  echo assets/logo.svg
  find skills -type f -name '*.md' | LC_ALL=C sort
} | zip -X -q "$out" -@

echo "wrote $out"
unzip -l "$out"
