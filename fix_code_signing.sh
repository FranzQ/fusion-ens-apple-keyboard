#!/bin/bash

# Script to fix code signing conflict for App Store distribution
echo "🔧 Fixing code signing conflict..."

# Backup the project file
cp "Fusion ENS.xcodeproj/project.pbxproj" "Fusion ENS.xcodeproj/project.pbxproj.backup2"
echo "✅ Created backup of project file"

# Remove manual CODE_SIGN_IDENTITY to let Xcode handle it automatically
sed -i '' 's/CODE_SIGN_IDENTITY = "Apple Distribution";//g' "Fusion ENS.xcodeproj/project.pbxproj"
echo "✅ Removed manual CODE_SIGN_IDENTITY settings"

# Ensure CODE_SIGN_STYLE is Automatic
sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' "Fusion ENS.xcodeproj/project.pbxproj"
echo "✅ Ensured CODE_SIGN_STYLE is Automatic"

# Ensure DEVELOPMENT_TEAM is set
sed -i '' 's/DEVELOPMENT_TEAM = "";/DEVELOPMENT_TEAM = WC7S9A7PR9;/g' "Fusion ENS.xcodeproj/project.pbxproj"
echo "✅ Ensured DEVELOPMENT_TEAM is set"

echo ""
echo "🎉 Code signing conflict fixed!"
echo ""
echo "Now in Xcode:"
echo "1. Go to Signing & Capabilities for each target"
echo "2. Make sure 'Automatically manage signing' is checked"
echo "3. Select your Team (Franz Quarshie)"
echo "4. Xcode will automatically choose the right certificate"
echo ""
echo "For App Store submission:"
echo "- Xcode will use 'Apple Distribution' automatically when archiving"
echo "- For development, it will use 'Apple Development'"
