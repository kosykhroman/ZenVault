#!/bin/bash

APP_NAME="ZenVault"
BUNDLE_DIR="$APP_NAME.app"

echo "🧹 Очищаем старую сборку..."
rm -rf "$BUNDLE_DIR"

echo "📁 Создаем структуру .app..."
mkdir -p "$BUNDLE_DIR/Contents/MacOS"
mkdir -p "$BUNDLE_DIR/Contents/Resources"

echo "🔨 Компилируем Swift..."
swiftc -o "$BUNDLE_DIR/Contents/MacOS/$APP_NAME" ZenVault.swift -framework Cocoa

echo "🎨 Добавляем иконку..."
if [ -f "app_icon.png" ]; then
    cp app_icon.png "$BUNDLE_DIR/Contents/Resources/"
else
    echo "⚠️ app_icon.png не найден, иконка не будет добавлена."
fi

echo "📝 Создаем Info.plist..."
cat > "$BUNDLE_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ZenVault</string>
    <key>CFBundleIdentifier</key>
    <string>com.zenvault.app</string>
    <key>CFBundleName</key>
    <string>ZenVault</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>app_icon</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Готово! Приложение собрано в $BUNDLE_DIR"
echo "🚀 Запусти: open $BUNDLE_DIR"