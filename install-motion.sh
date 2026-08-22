#!/usr/bin/env bash
set -e

echo "=========================================="
echo "  Next.js Animation & Icon Setup Script   "
echo "=========================================="

if [ ! -f "package.json" ]; then
  echo "[ERROR] package.json not found. Run this from the root of your Next.js project."
  exit 1
fi

PKG_MANAGER="npm"
ADD_CMD="install"

if [ -f "pnpm-lock.yaml" ]; then
  PKG_MANAGER="pnpm"
  ADD_CMD="add"
elif [ -f "yarn.lock" ]; then
  PKG_MANAGER="yarn"
  ADD_CMD="add"
elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
  PKG_MANAGER="bun"
  ADD_CMD="add"
fi

echo "[+] Using package manager: $PKG_MANAGER"

if [ ! -d "node_modules" ]; then
  echo "[+] Installing base project dependencies..."
  $PKG_MANAGER install
fi

echo "[+] Installing framer-motion lucide-react clsx tailwind-merge..."
$PKG_MANAGER $ADD_CMD framer-motion lucide-react clsx tailwind-merge

if [ ! -f "src/lib/utils.ts" ] && [ ! -f "lib/utils.ts" ]; then
  TARGET_DIR="lib"
  if [ -d "src" ]; then
    TARGET_DIR="src/lib"
  fi
  mkdir -p "$TARGET_DIR"
  cat << 'EOF' > "$TARGET_DIR/utils.ts"
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
EOF
  echo "[OK] Created $TARGET_DIR/utils.ts"
fi

echo "[OK] Setup completed successfully! Run 'npm run dev' to start."
