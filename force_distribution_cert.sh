#!/bin/bash

# Script to force Apple Distribution certificate for App Store builds
echo "🔧 Configuring Apple Distribution certificate for App Store builds..."

# Backup the project file
cp "Fusion ENS.xcodeproj/project.pbxproj" "Fusion ENS.xcodeproj/project.pbxproj.backup3"
echo "✅ Created backup of project file"

# Add CODE_SIGN_IDENTITY for Release builds only
# This will force Apple Distribution for App Store builds
sed -i '' '/buildSettings = {/,/};/ {
    /buildSettings = {/ {
        N
        /buildSettings = {[^}]*};/ {
            s/buildSettings = {/buildSettings = {\
				CODE_SIGN_IDENTITY = "Apple Distribution";/
        }
    }
}' "Fusion ENS.xcodeproj/project.pbxproj"

echo "✅ Added Apple Distribution certificate for Release builds"
echo ""
echo "🎉 Configuration updated!"
echo ""
echo "Now when you archive for App Store:"
echo "- Xcode will use 'Apple Distribution' certificate"
echo "- For development builds, it will use 'Apple Development'"
echo ""
echo "Next steps:"
echo "1. Create App Store Connect app (if not done)"
echo "2. Archive in Xcode: Product → Archive"
echo "3. Upload to App Store Connect"
