#!/bin/bash

# Script to update code signing for App Store distribution
echo "🔐 Updating code signing settings for App Store distribution..."

# Backup the project file
cp "Fusion ENS.xcodeproj/project.pbxproj" "Fusion ENS.xcodeproj/project.pbxproj.backup"
echo "✅ Created backup of project file"

# Update CODE_SIGN_IDENTITY to Apple Distribution for Release builds
sed -i '' 's/CODE_SIGN_IDENTITY = "Apple Development";/CODE_SIGN_IDENTITY = "Apple Distribution";/g' "Fusion ENS.xcodeproj/project.pbxproj"
echo "✅ Updated CODE_SIGN_IDENTITY to Apple Distribution"

# Ensure DEVELOPMENT_TEAM is set for all targets
sed -i '' 's/DEVELOPMENT_TEAM = "";/DEVELOPMENT_TEAM = WC7S9A7PR9;/g' "Fusion ENS.xcodeproj/project.pbxproj"
echo "✅ Updated DEVELOPMENT_TEAM settings"

# Update CODE_SIGN_STYLE to Automatic (recommended for App Store)
sed -i '' 's/CODE_SIGN_STYLE = Manual;/CODE_SIGN_STYLE = Automatic;/g' "Fusion ENS.xcodeproj/project.pbxproj"
echo "✅ Updated CODE_SIGN_STYLE to Automatic"

echo ""
echo "🎉 Code signing settings updated!"
echo ""
echo "Next steps:"
echo "1. Open Xcode and verify the settings"
echo "2. Create App Store Distribution certificate if needed"
echo "3. Test build on device"
echo "4. Archive for App Store submission"
