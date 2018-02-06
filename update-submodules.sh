#!/bin/bash
BASEDIR=$(dirname "$0")

echo '######################## lade alle git submodules #################################'
git submodule init
git submodule update
echo '######################## lade alle git submodules #################################'