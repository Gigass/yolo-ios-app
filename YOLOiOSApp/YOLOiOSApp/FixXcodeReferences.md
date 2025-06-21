# Fix Xcode Project References

## Issue
The Xcode project is referencing the old ModelSizeHelper.swift location that was deleted. The file now exists at:
`YOLOiOSApp/Utilities/ModelSizeHelper.swift`

## Steps to Fix in Xcode:

### 1. Remove Old Reference
1. Open YOLOiOSApp.xcodeproj in Xcode
2. In the project navigator, find the red (missing) ModelSizeHelper.swift file
3. Right-click and select "Delete" → "Remove Reference"

### 2. Add New SwiftUI Files
Add all the new SwiftUI files to the project:

```
YOLOiOSApp/App.swift
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

### 3. To Add Files:
1. Right-click on the YOLOiOSApp folder in Xcode
2. Select "Add Files to YOLOiOSApp..."
3. Navigate to each folder and select the Swift files
4. Make sure "Copy items if needed" is unchecked (files are already in place)
5. Make sure "YOLOiOSApp" target is checked
6. Click "Add"

### 4. Organize in Groups (Optional):
Create groups in Xcode to match the folder structure:
- Extensions
- Utilities  
- ViewModels
- Views
  - Camera
  - Components

### 5. Update Info.plist (if using SwiftUI as main app):
If you want to use the SwiftUI App as the main entry point, update Info.plist:
- Remove "Main storyboard file base name" (UIMainStoryboardFile)
- Remove "Application Scene Manifest" if not using scenes with SwiftUI

### 6. Alternative - Keep UIKit Entry Point:
If you want to keep the current UIKit entry point and gradually migrate:
- Keep the current Main.storyboard setup
- The RootView.swift already handles toggling between old and new UI
- Users can switch between interfaces using the AppState.isNewUIActive property

## Quick Command to List All New Files:
```bash
find YOLOiOSApp -name "*.swift" -path "*/Extensions/*" -o -path "*/Utilities/*" -o -path "*/ViewModels/*" -o -path "*/Views/*" -o -name "App.swift" | grep -v ".xcodeproj" | sort
```