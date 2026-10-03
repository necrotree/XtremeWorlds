#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../SpacetimeDb"
spacetime build
spacetime publish xtremeworlds -y
