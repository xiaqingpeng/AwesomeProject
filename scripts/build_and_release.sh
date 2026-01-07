#!/usr/bin/env bash
set -euo pipefail

# === 配置区域 ===
# 如果在 GitHub Actions 中，会自动提供 GITHUB_REPOSITORY；本地则从 git remote 解析
REPO_SLUG="${GITHUB_REPOSITORY:-}"
# BSD/macOS 的 date 需要加引号，否则会报 “illegal time format”
TAG_NAME="${TAG_NAME:-local-build-$(date "+%Y%m%d%H%M%S")}"
RELEASE_TITLE="${RELEASE_TITLE:-Local Build $(date "+%Y-%m-%d %H:%M:%S")}"

usage() {
  cat <<'EOF'
用法: ./scripts/build_and_release.sh [--tag TAG] [--title TITLE]
示例:
  ./scripts/build_and_release.sh --tag v2.0.0 --title "v2.0.0 Release"

说明:
  --tag / TAG_NAME      自定义 Release Tag（默认带时间戳）
  --title / RELEASE_TITLE 自定义 Release 标题
EOF
}

# 解析简单参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --tag)
      TAG_NAME="$2"; shift 2;;
    --title)
      RELEASE_TITLE="$2"; shift 2;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "未知参数: $1"; usage; exit 1;;
  esac
done

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FASTLANE_DIR="$ROOT_DIR/fastlane"

# 检查依赖
command -v pnpm >/dev/null || { echo "pnpm 未安装"; exit 1; }
command -v bundle >/dev/null || { echo "bundle 未安装"; exit 1; }
command -v gh >/dev/null || { echo "GitHub CLI gh 未安装"; exit 1; }

echo "=== 安装 JS 依赖（pnpm）==="
cd "$ROOT_DIR"
pnpm install

echo "=== 安装 Ruby 依赖（bundle）==="
cd "$FASTLANE_DIR"
BUNDLE_GEMFILE="$FASTLANE_DIR/Gemfile" bundle install

echo "=== 构建 Android Release（fastlane android build）==="
cd "$FASTLANE_DIR"
BUNDLE_GEMFILE="$FASTLANE_DIR/Gemfile" bundle exec fastlane android build

ensure_apk() {
  # 查找并复制 APK 到仓库根目录，文件名带上 tag 方便区分版本
  APK_PATH="$ROOT_DIR/app-release-${TAG_NAME}.apk"
  ANDROID_APK_SRC="$ROOT_DIR/android/app/build/outputs/apk/release/app-release.apk"

  if [ ! -f "$ANDROID_APK_SRC" ]; then
    # 尝试自动查找任意 release APK（包含 split-per-abi 等）
    FOUND_APK="$(find "$ROOT_DIR/android/app/build/outputs/apk" -type f -name '*release*.apk' 2>/dev/null | head -n 1 || true)"
    if [ -n "$FOUND_APK" ]; then
      ANDROID_APK_SRC="$FOUND_APK"
    fi
  fi

  if [ -f "$ANDROID_APK_SRC" ]; then
    cp "$ANDROID_APK_SRC" "$APK_PATH"
    echo "✓ Android APK 已复制到: $APK_PATH (源文件: $ANDROID_APK_SRC)"
  else
    echo "未找到任何 release APK，请检查路径："
    echo "  尝试的默认路径: $ROOT_DIR/android/app/build/outputs/apk/release/app-release.apk"
    echo "  当前 outputs 目录下的 APK 文件:"
    find "$ROOT_DIR/android/app/build/outputs" -type f -name '*.apk' 2>/dev/null || echo "  (没有找到任何 APK)"
    exit 1
  fi
}
# 执行 APK 查找并复制
ensure_apk

echo "=== 构建 iOS Release（fastlane ios build）==="
cd "$FASTLANE_DIR"
# 确保使用 fastlane 目录下的 Gemfile 运行 pod / fastlane
BUNDLE_GEMFILE="$FASTLANE_DIR/Gemfile" bundle exec fastlane ios build

# 查找并复制 iOS .app 到仓库根目录，然后压缩为 zip 供 GitHub 上传（文件名带 tag）
IOS_APP_SRC_PRIMARY="$ROOT_DIR/ios/build/Build/Products/Release-iphoneos/AwesomeProject.app"
IOS_APP_SRC_ARCHIVE="$ROOT_DIR/ios/build/AwesomeProject.xcarchive/Products/Applications/AwesomeProject.app"
IOS_APP_DIR="$ROOT_DIR/AwesomeProject.app"
IOS_APP_ZIP="$ROOT_DIR/AwesomeProject-${TAG_NAME}.app.zip"

if [ -d "$IOS_APP_SRC_PRIMARY" ]; then
  cp -R "$IOS_APP_SRC_PRIMARY" "$IOS_APP_DIR"
  echo "✓ iOS App 已复制到: $IOS_APP_DIR"
elif [ -d "$IOS_APP_SRC_ARCHIVE" ]; then
  cp -R "$IOS_APP_SRC_ARCHIVE" "$IOS_APP_DIR"
  echo "✓ iOS App 已从归档复制到: $IOS_APP_DIR"
else
  echo "未找到 iOS App：$IOS_APP_SRC_PRIMARY 或 $IOS_APP_SRC_ARCHIVE"
  exit 1
fi

echo "=== 压缩 iOS .app 为 zip 以便上传到 GitHub ==="
rm -f "$IOS_APP_ZIP"
# 使用 ditto 保留 .app 结构和资源
ditto -c -k --sequesterRsrc --keepParent "$IOS_APP_DIR" "$IOS_APP_ZIP"
echo "✓ iOS App 已压缩为: $IOS_APP_ZIP"

# 后续上传使用 zip 文件
APP_PATH="$IOS_APP_ZIP"

echo "=== 创建 GitHub Release 并上传附件 ==="
cd "$ROOT_DIR"

# 如果 REPO_SLUG 为空，从 git remote 解析仓库 (参考 QT 脚本实现)
if [ -z "$REPO_SLUG" ]; then
  REMOTE_NAME="origin"
  REMOTE_URL=$(git remote get-url "$REMOTE_NAME" 2>/dev/null || true)
  if [[ "$REMOTE_URL" =~ github\.com[:/]([^/]+)/([^/]+)(\.git)?$ ]]; then
    GITHUB_USER="${BASH_REMATCH[1]}"
    GITHUB_REPO="${BASH_REMATCH[2]}"
    GITHUB_REPO="${GITHUB_REPO%.git}"
    REPO_SLUG="$GITHUB_USER/$GITHUB_REPO"
  else
    echo "无法从 git remote 解析 GitHub 仓库，请设置 GITHUB_REPOSITORY 或在脚本顶部配置 REPO_SLUG"
    exit 1
  fi
fi

echo "目标仓库: $REPO_SLUG"

# 确认 gh 已认证
if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI 未认证，请先运行: gh auth login"
  exit 1
fi

# 如果 Release 已存在，则覆盖上传资产；否则创建新的 Release
if gh release view "$TAG_NAME" --repo "$REPO_SLUG" >/dev/null 2>&1; then
  echo "Release $TAG_NAME 已存在，上传/覆盖附件..."
  gh release upload "$TAG_NAME" \
    "$APK_PATH#Android APK ($TAG_NAME)" \
    "$APP_PATH#iOS App Bundle ($TAG_NAME)" \
    --repo "$REPO_SLUG" \
    --clobber
else
  echo "Release $TAG_NAME 不存在，创建新的 Release..."
  gh release create "$TAG_NAME" \
    "$APK_PATH#Android APK ($TAG_NAME)" \
    "$APP_PATH#iOS App Bundle ($TAG_NAME)" \
    --repo "$REPO_SLUG" \
    --title "$RELEASE_TITLE" \
    --notes "Auto-built by local script" \
    --draft
fi

echo "完成！"
echo "Release: https://github.com/$REPO_SLUG/releases/tag/$TAG_NAME"
echo "附件：app-release.apk, AwesomeProject.app（已上传到 Release）"