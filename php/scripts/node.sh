#!/usr/bin/env bash

set -euo pipefail

# NODE JS
curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get install nodejs -yq \
    && npm i -g --force npm \
    && npm cache clean --force

