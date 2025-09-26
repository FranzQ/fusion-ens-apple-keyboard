# Accessibility Testing Guide for Fusion ENS Keyboard

## Overview
This guide provides instructions for testing the accessibility features implemented in the Fusion ENS iOS Keyboard.

## Testing Prerequisites
1. iOS device with VoiceOver enabled
2. Fusion ENS Keyboard installed and enabled
3. Test app (Notes, Messages, or any text input app)

## VoiceOver Testing Steps

### 1. Enable VoiceOver
1. Go to Settings > Accessibility > VoiceOver
2. Turn on VoiceOver
3. Learn basic VoiceOver gestures:
   - Single tap: Select item
   - Double tap: Activate item
   - Swipe right/left: Navigate between items
   - Two-finger tap: Stop current action

### 2. Test Basic Keyboard Navigation
1. Open Notes app
2. Switch to Fusion ENS Keyboard (Pro version)
3. Navigate through keyboard buttons using VoiceOver
4. Verify each button announces:
   - Button name (e.g., "A key", "Space", "Delete")
   - Button function (e.g., "Double tap to insert A")
   - Special functions (e.g., "Long press to resolve ENS names")

### 3. Test Keyboard Layout Switching
1. Navigate to "123" button
2. Double tap to switch to numbers
3. Verify announcement: "Switched to numbers keyboard"
4. Navigate to "ABC" button
5. Double tap to switch back to letters
6. Verify announcement: "Switched to letters keyboard"

### 4. Test ENS Resolution
1. Type "vitalik.eth" in text field
2. Select the text
3. Long press space bar
4. Verify announcement: "Resolving ENS name"
5. Wait for resolution
6. Verify announcement: "ENS name vitalik.eth resolved to address [address]"

### 5. Test Suggestion Bar
1. Type "vital" in text field
2. Navigate to suggestion bar
3. Verify suggestions are announced as "Suggestion: [name]"
4. Double tap a suggestion
5. Verify text is inserted correctly

### 6. Test High Contrast Mode
1. Go to Settings > Accessibility > Display & Text Size > Increase Contrast
2. Turn on "Increase Contrast"
3. Open keyboard and verify:
   - Buttons have higher contrast
   - Text is more readable
   - Borders are visible on letter keys

### 7. Test Dynamic Type
1. Go to Settings > Accessibility > Display & Text Size > Larger Text
2. Increase text size to largest setting
3. Open keyboard and verify:
   - Button text scales appropriately
   - Layout remains functional
   - All buttons are still accessible

## Expected Results

### VoiceOver Navigation
- All keyboard buttons should be discoverable
- Each button should have descriptive labels
- Navigation should be logical and intuitive
- No buttons should be skipped or inaccessible

### Announcements
- Key presses should be announced
- Layout changes should be announced
- ENS resolution should be announced
- Error states should be announced

### Visual Accessibility
- High contrast mode should improve readability
- Dynamic Type should scale text appropriately
- Colors should meet accessibility guidelines

## Common Issues to Check

### Missing Labels
- Buttons without accessibility labels
- Unclear or confusing button descriptions
- Missing hints for complex actions

### Navigation Problems
- Buttons that can't be reached
- Inconsistent navigation order
- Missing or incorrect traits

### Announcement Issues
- Missing announcements for important actions
- Unclear or confusing announcements
- Timing issues with announcements

## Testing Checklist

- [ ] All keyboard buttons are accessible via VoiceOver
- [ ] Button labels are descriptive and clear
- [ ] Button hints explain functionality
- [ ] Layout switching is announced
- [ ] ENS resolution is announced
- [ ] Suggestion bar is accessible
- [ ] High contrast mode works
- [ ] Dynamic Type scaling works
- [ ] No accessibility errors in console
- [ ] Performance is acceptable with VoiceOver

## Reporting Issues

When reporting accessibility issues, include:
1. iOS version
2. VoiceOver version
3. Specific steps to reproduce
4. Expected vs actual behavior
5. Screenshots or screen recordings if helpful

## Additional Resources

- [Apple Accessibility Guidelines](https://developer.apple.com/accessibility/)
- [VoiceOver User Guide](https://support.apple.com/guide/voiceover/)
- [iOS Accessibility Testing](https://developer.apple.com/accessibility/ios/)
