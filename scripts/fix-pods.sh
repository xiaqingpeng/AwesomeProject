#!/bin/bash

# Fix CocoaPods null byte error with pnpm workspace
# This script cleans and reinstalls CocoaPods dependencies

set -e

echo "🔧 Fixing CocoaPods null byte error..."

# Navigate to project root
cd "$(dirname "$0")/.."

echo "📦 Reinstalling pnpm dependencies..."
rm -rf node_modules
pnpm install

echo "🧹 Cleaning CocoaPods cache..."
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all || true

echo "📱 Installing CocoaPods dependencies..."
export COCOAPODS_DISABLE_STATS=true
export NODE_PATH=$(pwd)/node_modules
cd ios
pod install --repo-update

echo "✅ Done! CocoaPods dependencies installed successfully."

