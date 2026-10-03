#!/usr/bin/env bash
set -euo pipefail
dotnet run --project "$(dirname "$0")/../src/Server/Server.vbproj"
