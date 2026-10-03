#!/usr/bin/env bash
set -euo pipefail
UI="${1:-GTK}"
CONFIG="${2:-Debug}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

case "$UI" in
  Windows) PROJECT="$ROOT/Platforms/Windows/Server.Windows.csproj" ;;
  GTK) PROJECT="$ROOT/Platforms/GTK/Server.GTK.csproj" ;;
  macOS) PROJECT="$ROOT/Platforms/macOS/Server.macOS.csproj" ;;
  *) echo "Usage: $0 [Windows|GTK|macOS] [Debug|Release]"; exit 2 ;;
esac

dotnet run --project "$PROJECT" -c "$CONFIG"
