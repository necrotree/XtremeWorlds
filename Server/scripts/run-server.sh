#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
case "$(uname -s)" in
  Darwin) PROJECT="$ROOT/Platforms/macOS/Server.macOS.csproj" ;;
  *) PROJECT="$ROOT/Platforms/GTK/Server.GTK.csproj" ;;
esac
dotnet run --project "$PROJECT"
