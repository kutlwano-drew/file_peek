#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

VERSION="${RELEASE_TAG#v}"
PACKAGE_VERSION="${VERSION%%-*}"

BUNDLE_DIR="$ROOT_DIR/build/linux/x64/release/bundle"
DIST_DIR="$ROOT_DIR/dist/linux"

DESKTOP_FILE="$ROOT_DIR/packaging/linux/file-peek.desktop"
ICON_FILE="$ROOT_DIR/assets/images/filepeek.png"

STAGE_DIR="$ROOT_DIR/build/linux/package-stage"
APPIMAGE_DIR="$ROOT_DIR/build/linux/AppDir"

rm -rf "$DIST_DIR"
rm -rf "$STAGE_DIR"
rm -rf "$APPIMAGE_DIR"

mkdir -p "$DIST_DIR"
mkdir -p "$STAGE_DIR/opt/file-peek"
mkdir -p "$STAGE_DIR/usr/bin"
mkdir -p "$STAGE_DIR/usr/share/applications"
mkdir -p "$STAGE_DIR/usr/share/icons/hicolor/256x256/apps"

if [[ ! -d "$BUNDLE_DIR" ]]; then
    echo "Linux Flutter bundle not found:"
    echo "$BUNDLE_DIR"
    exit 1
fi

if [[ ! -f "$BUNDLE_DIR/file_peek" ]]; then
    echo "File Peek Linux executable not found:"
    echo "$BUNDLE_DIR/file_peek"
    exit 1
fi

if [[ ! -f "$ICON_FILE" ]]; then
    echo "File Peek icon not found:"
    echo "$ICON_FILE"
    exit 1
fi

cp -a "$BUNDLE_DIR/." "$STAGE_DIR/opt/file-peek/"

sed \
    -e 's|^Exec=.*|Exec=file-peek %F|' \
    -e 's|^Icon=.*|Icon=filepeek|' \
    "$DESKTOP_FILE" \
    > "$STAGE_DIR/usr/share/applications/file-peek.desktop"

if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate "$STAGE_DIR/usr/share/applications/file-peek.desktop"
fi

cp "$ICON_FILE" \
    "$STAGE_DIR/usr/share/icons/hicolor/256x256/apps/filepeek.png"

ln -s /opt/file-peek/file_peek \
    "$STAGE_DIR/usr/bin/file-peek"

chmod +x "$STAGE_DIR/opt/file-peek/file_peek"

echo "Building Debian package..."

fpm \
    -s dir \
    -t deb \
    -n file-peek \
    -v "$PACKAGE_VERSION" \
    -a amd64 \
    --maintainer "Kutlwano P. Maruatona" \
    --description "Inspect files and project structures." \
    --category utils \
    --url "https://github.com/kutlwano-drew/file_peek" \
    --depends "libgtk-3-0" \
    --depends "libblkid1" \
    --depends "liblzma5" \
    -C "$STAGE_DIR" \
    -p "$DIST_DIR/File-Peek-${RELEASE_TAG}-linux-amd64.deb" \
    opt/file-peek \
    usr/bin/file-peek \
    usr/share/applications/file-peek.desktop \
    usr/share/icons/hicolor/256x256/apps/filepeek.png

echo "Building RPM package..."

fpm \
    -s dir \
    -t rpm \
    -n file-peek \
    -v "$PACKAGE_VERSION" \
    -a x86_64 \
    --maintainer "Kutlwano P. Maruatona" \
    --description "Inspect files and project structures." \
    --category utils \
    --url "https://github.com/kutlwano-drew/file_peek" \
    --depends "gtk3" \
    --depends "util-linux" \
    --depends "xz-libs" \
    -C "$STAGE_DIR" \
    -p "$DIST_DIR/File-Peek-${RELEASE_TAG}-linux-x86_64.rpm" \
    opt/file-peek \
    usr/bin/file-peek \
    usr/share/applications/file-peek.desktop \
    usr/share/icons/hicolor/256x256/apps/filepeek.png

echo "Building TAR.GZ package..."

TAR_DIR="$ROOT_DIR/build/linux/file-peek-${RELEASE_TAG}-linux-x64"

rm -rf "$TAR_DIR"

mkdir -p "$TAR_DIR"

cp -a "$BUNDLE_DIR/." "$TAR_DIR/"

tar \
    -C "$ROOT_DIR/build/linux" \
    -czf "$DIST_DIR/File-Peek-${RELEASE_TAG}-linux-x64.tar.gz" \
    "file-peek-${RELEASE_TAG}-linux-x64"

rm -rf "$TAR_DIR"

echo "Building AppImage..."

mkdir -p "$APPIMAGE_DIR/usr/bin"
mkdir -p "$APPIMAGE_DIR/usr/share/applications"
mkdir -p "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps"

cp -a "$BUNDLE_DIR/." \
    "$APPIMAGE_DIR/usr/bin/"

cp "$DESKTOP_FILE" \
    "$APPIMAGE_DIR/usr/share/applications/file-peek.desktop"

cp "$ICON_FILE" \
    "$APPIMAGE_DIR/usr/share/icons/hicolor/256x256/apps/filepeek.png"

cp "$DESKTOP_FILE" \
    "$APPIMAGE_DIR/file-peek.desktop"

cp "$ICON_FILE" \
    "$APPIMAGE_DIR/filepeek.png"

sed -i \
    's|^Exec=.*|Exec=file_peek %F|' \
    "$APPIMAGE_DIR/file-peek.desktop"

chmod +x "$APPIMAGE_DIR/usr/bin/file_peek"

curl \
    -L \
    --fail \
    --retry 3 \
    -o "$ROOT_DIR/build/linux/linuxdeploy.AppImage" \
    "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"

chmod +x "$ROOT_DIR/build/linux/linuxdeploy.AppImage"

APPIMAGE_EXTRACT_AND_RUN=1 \
    "$ROOT_DIR/build/linux/linuxdeploy.AppImage" \
    --appdir "$APPIMAGE_DIR" \
    --executable "$APPIMAGE_DIR/usr/bin/file_peek" \
    --desktop-file "$APPIMAGE_DIR/file-peek.desktop" \
    --icon-file "$APPIMAGE_DIR/filepeek.png" \
    --output appimage

GENERATED_APPIMAGE="$(find "$ROOT_DIR/build/linux" -maxdepth 1 -type f -name '*.AppImage' -print -quit)"

if [[ -z "$GENERATED_APPIMAGE" ]]; then
    echo "AppImage was not created."
    exit 1
fi

mv "$GENERATED_APPIMAGE" \
    "$DIST_DIR/File-Peek-${RELEASE_TAG}-linux-x86_64.AppImage"

echo "Building Snap..."

SNAP_BUILD_DIR="$ROOT_DIR/build/linux/snap"

rm -rf "$SNAP_BUILD_DIR"

mkdir -p "$SNAP_BUILD_DIR/file-peek-bundle"

cp -a "$BUNDLE_DIR/." \
    "$SNAP_BUILD_DIR/file-peek-bundle/"

mkdir -p "$SNAP_BUILD_DIR/gui"

cp "$DESKTOP_FILE" \
    "$SNAP_BUILD_DIR/gui/file-peek.desktop"

cp "$ICON_FILE" \
    "$SNAP_BUILD_DIR/gui/filepeek.png"

cp "$ROOT_DIR/packaging/snap/snapcraft.yaml" \
    "$SNAP_BUILD_DIR/snapcraft.yaml"

(
    cd "$SNAP_BUILD_DIR"

    snapcraft pack \
        --destructive-mode \
        --output "$DIST_DIR"
)

SNAP_FILE="$(find "$DIST_DIR" -maxdepth 1 -type f -name '*.snap' -print -quit)"

if [[ -z "$SNAP_FILE" ]]; then
    echo "Snap package was not created."
    exit 1
fi

mv "$SNAP_FILE" \
    "$DIST_DIR/File-Peek-${RELEASE_TAG}-linux-amd64.snap"

echo

echo "Linux packages created:"

find "$DIST_DIR" -maxdepth 1 -type f -print