#!/bin/sh
set -eu

cd "$(dirname "$0")"
export BUNDLE_GEMFILE="$PWD/Gemfile"

if ! bundle _2.4.22_ check >/dev/null; then
  printf '%s\n' 'Install the preview dependencies using the Local preview section in README.md.' >&2
  exit 1
fi

exec bundle _2.4.22_ exec jekyll serve --host 127.0.0.1 --port "${PORT:-4173}" --watch
