#!/usr/bin/env bash
set -euo pipefail
UI="${1:-GTK}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
case "${UI,,}" in
  windows) PROJECT="$ROOT/Platforms/Windows/Server.Windows.csproj" ;;
  gtk|linux) PROJECT="$ROOT/Platforms/GTK/Server.GTK.csproj" ;;
  macos|mac) PROJECT="$ROOT/Platforms/macOS/Server.macOS.csproj" ;;
  *) echo "Usage: $0 [Windows|GTK|macOS]" >&2; exit 2 ;;
esac
echo "Starting XtremeWorlds Server UI: $UI"
dotnet run --project "$PROJECT"
