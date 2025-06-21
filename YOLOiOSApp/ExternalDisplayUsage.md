# External Display Support for YOLO iOS App

## Overview
The YOLO iOS app now supports external display functionality, allowing you to display the camera feed and YOLO detection results on an external monitor while keeping the iPhone screen for controls only.

## Requirements
- iPhone with USB-C port (iPhone 15 Pro/Pro Max, iPhone 16 series) for direct connection
- OR iPhone with Lightning port + Lightning to Digital AV Adapter + HDMI cable
- External display (Apple Studio Display, Dell monitors, or any HDMI/USB-C compatible display)
- iOS 16.0 or later

## How to Use

### Connecting Your Display

#### For USB-C iPhones (iPhone 15 Pro/Pro Max, iPhone 16 series):
1. Connect your iPhone directly to the display using a USB-C cable
2. The display should automatically detect the signal

#### For Lightning iPhones:
1. Connect Lightning to Digital AV Adapter to your iPhone
2. Connect HDMI cable from adapter to display
3. Ensure display is set to correct HDMI input

### Using the App with External Display

1. **Launch the app normally** on your iPhone
2. **Connect the external display** - the app will automatically detect it
3. When connected:
   - iPhone screen shows "📱 Camera is shown on external display" message
   - External display shows full-screen camera feed with YOLO detections
   - All UI controls remain on iPhone for easy access

4. **To disconnect**: Simply unplug the cable
   - Camera feed automatically returns to iPhone screen

## Features

### Automatic Resolution Selection
- Supports up to 5K resolution (5120×2880) on compatible displays
- Automatically selects the highest available resolution
- Works with Apple Studio Display at full 5K resolution

### Real-time Performance
- Camera feed and YOLO detections run at full speed on external display
- No lag or delay between detection and display
- All YOLO tasks supported: Detect, Segment, Classify, Pose, OBB

### Clean External Display
- External display shows only camera feed and detection results
- No UI elements, buttons, or sliders on external display
- Professional presentation mode for demonstrations

## Troubleshooting

### "No USB-C signal" message on display
- Ensure cable is properly connected at both ends
- Try a different USB-C cable (some cables are charge-only)
- For Dell displays: Check that USB-C input is selected in display menu

### Black screen on external display
- Wait a few seconds for the connection to establish
- Try disconnecting and reconnecting the cable
- Ensure the app has camera permissions in iOS Settings

### Display shows home screen but not app
- This is normal behavior - the app content appears when camera starts
- If camera doesn't start, check camera permissions
- Try force-quitting and relaunching the app

## Technical Details

### Architecture
- Uses iOS Scene Delegate architecture for multi-window support
- Shares AVCaptureSession between displays (iOS limitation: one camera session)
- Real-time synchronization of detection results between displays

### Supported Display Modes
- External Display Role (UIWindowSceneSessionRoleExternalDisplay)
- Overscan compensation enabled for edge-to-edge display
- Automatic display mode selection based on available resolutions

## Known Limitations

1. **Camera location**: Camera feed can only be displayed on one screen at a time (iOS limitation)
2. **Simulator**: External display features require a physical device for testing
3. **Display compatibility**: Some displays may require specific cable types or adapters

## Future Enhancements

Potential improvements for future versions:
- Picture-in-picture mode on iPhone while using external display
- Custom UI layouts for external display
- Multi-display support for presentation scenarios
- Recording capabilities from external display view