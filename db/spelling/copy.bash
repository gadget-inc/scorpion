#!/usr/bin/env bash
# Script for copying select dictionaries from https://github.com/wooorm/dictionaries into this repo
# Usage: bash copy.bash path/to/that/repo

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source=$1
destination=$DIR/dictionaries

rm -rf $destination/*

declare -a langs=("en-US" "en-CA" "en-GB" "fr" "de" "es" "ko" "pt" "pt-BR")

for lang in ${langs[@]}; do
  cp $1/dictionaries/$lang/index.aff $destination/$lang.aff
  cp $1/dictionaries/$lang/index.dic $destination/$lang.dic
done