#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${XCODE13_SDK_PATH:?Set XCODE13_SDK_PATH to the verified legacy SDK stubs}"
SDK=$(xcrun --sdk iphoneos --show-sdk-path)
CLANG=$(xcrun -f clang)
SDK_VERSION=$(plutil -extract Version raw "$SDK/SDKSettings.plist")
OUT="$PWD/build/olmos"
APP="$OUT/Payload/OlmosKiosk.app"
mkdir -p "$APP"
for ARCH in armv7 arm64; do
    FLAGS=()
    if [[ "$ARCH" == armv7 ]]; then FLAGS=(-marm); fi
    "$CLANG" --target="$ARCH-apple-ios9.0" -isysroot "$SDK" \
        -fobjc-arc -fmodules -Os -Werror=unguarded-availability \
        "${FLAGS[@]}" -c OlmosKiosk/main.m -o "$OUT/$ARCH.o"
    "$CLANG" --target="$ARCH-apple-ios9.0" -isysroot "$XCODE13_SDK_PATH" \
        -fobjc-arc "${FLAGS[@]}" -framework Foundation -framework UIKit -framework WebKit \
        -Xlinker -platform_version -Xlinker ios -Xlinker 9.0 -Xlinker "$SDK_VERSION" \
        "$OUT/$ARCH.o" -o "$OUT/$ARCH"
    test "$(lipo -archs "$OUT/$ARCH")" = "$ARCH"
    MIN=$(otool -l "$OUT/$ARCH" | awk '$1=="cmd" && $2=="LC_VERSION_MIN_IPHONEOS"{p=1;next} p && $1=="version"{print $2;p=0}')
    test "$MIN" = 9.0
done
lipo -create "$OUT/armv7" "$OUT/arm64" -output "$APP/OlmosKiosk"
cp OlmosKiosk/Info.plist "$APP/Info.plist"
plutil -replace CFBundleVersion -string "${GITHUB_RUN_NUMBER:-1}" "$APP/Info.plist"
plutil -lint "$APP/Info.plist"
printf 'APPL????' > "$APP/PkgInfo"
# Deliberately unsigned: Sideloadly adds the user's own signature and profile on Windows.
(cd "$OUT" && /usr/bin/zip -qr Los-Olmos-iOS9-unsigned.ipa Payload)
python3 scripts/verify-olmos-ipa.py "$OUT/Los-Olmos-iOS9-unsigned.ipa"
shasum -a 256 "$OUT/Los-Olmos-iOS9-unsigned.ipa" > "$OUT/SHA256SUMS.txt"
