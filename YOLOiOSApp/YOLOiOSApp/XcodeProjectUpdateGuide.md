# Xcode Project Update Guide

## Build Errors Fixed

### 1. Files Renamed
- `App.swift` → `YOLOApp.swift` (to avoid @main conflict with AppDelegate)

### 2. Code Fixes Applied
- Fixed YOLOViewDelegate method signature in YOLOCameraView.swift
- Updated YOLOView property access (removed non-existent properties)
- Added captureRequested flag for photo capture coordination

## Required Xcode Project Updates

### 1. Remove Missing References
In Xcode project navigator:
- Remove red reference to `App.swift`
- Remove red reference to `ModelSizeHelper.swift` (if in wrong location)

### 2. Add New SwiftUI Files
Add these files to the project (they already exist on disk):

```
YOLOiOSApp/YOLOApp.swift (renamed from App.swift)
YOLOiOSApp/Extensions/Color+Ultralytics.swift
YOLOiOSApp/Extensions/ModelEntry+Task.swift
YOLOiOSApp/Utilities/ModelSizeHelper.swift
YOLOiOSApp/Utilities/RemoteModelRegistry.swift
YOLOiOSApp/ViewModels/YOLOViewModel.swift
YOLOiOSApp/Views/Camera/YOLOCameraView.swift
YOLOiOSApp/Views/Components/ModelPickerView.swift
YOLOiOSApp/Views/Components/ParameterEditorView.swift
YOLOiOSApp/Views/Components/ShutterBarView.swift
YOLOiOSApp/Views/Components/StatusBar.swift
YOLOiOSApp/Views/Components/TaskTabsView.swift
YOLOiOSApp/Views/Components/ToolbarView.swift
YOLOiOSApp/Views/RootView.swift
```

### 3. Project Structure
The app maintains UIKit as the main entry point (AppDelegate) while supporting SwiftUI views through:
- RootView.swift manages switching between old UIKit and new SwiftUI interfaces
- AppState.isNewUIActive controls which UI is shown
- YOLOCameraView wraps the existing YOLOView as UIViewRepresentable

### 4. Testing the New UI
After adding files to Xcode:
1. Build and run the project
2. The new SwiftUI UI should be active by default
3. To switch back to old UI, set `AppState.isNewUIActive = false`

## Architecture Notes
- Hybrid approach: UIKit app delegate with SwiftUI views
- YOLOView remains as UIKit component wrapped in UIViewRepresentable
- All new UI components are pure SwiftUI
- Maintains backward compatibility with existing functionality