# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the Ultralytics YOLO iOS app repository containing:
- **YOLO Swift Package** (Sources/YOLO/): A lightweight Swift package for integrating YOLO models into iOS/macOS apps
- **Main iOS App** (YOLOiOSApp/): Production app for real-time object detection with custom model support
- **Example Apps** (ExampleApps/): Sample implementations demonstrating YOLO package integration in SwiftUI and UIKit

## Platform Requirements

- iOS 16.0+
- macOS 10.15+
- tvOS 13.0+ (package supports, main app may not)
- watchOS 6.0+ (package supports, main app may not)
- Swift 5.10+
- Xcode 14.0+

## Build and Test Commands

### Swift Package Manager
- Run tests: `swift test`
- Build package: `swift build`
- Run single test: `swift test --filter YOLOMainTests`
- Clean build: `swift package clean`

### Xcode Projects
- Open any `.xcodeproj` file in Xcode to build individual apps
- Run tests in Xcode: `Cmd+U`
- Build and run apps: `Cmd+R` (requires physical iOS device for camera features)
- Run specific test file: Select test file in navigator and `Cmd+U`
- Clean build folder: `Shift+Cmd+K`
- Resolve package dependencies: `xcodebuild -resolvePackageDependencies`

### CI Build Commands
```bash
# Build and test with code coverage (from CI workflow)
xcodebuild \
  -scheme YOLO \
  -sdk iphonesimulator \
  -derivedDataPath Build/ \
  -destination "platform=iOS Simulator,name=iPhone 14" \
  -enableCodeCoverage YES \
  clean build test

# Generate code coverage report
xcrun llvm-cov export -format="lcov" -instr-profile "$PROFDATA_PATH" "$BINARY_PATH" > info.lcov
```

### Test Setup
- Most tests skip model validation by default (`SKIP_MODEL_TESTS = true`)
- To run full tests with models: 
  1. Set `SKIP_MODEL_TESTS = false` in build settings or test environment
  2. Download test models: `bash Tests/YOLOTests/Resources/download-test-models.sh`
  3. Models will be placed in appropriate test resource directories
- Test files with .backup extension contain model-dependent tests

## Architecture

### Core Components
- **YOLO Class** (Sources/YOLO/YOLO.swift): Main interface supporting multiple input types (UIImage, CIImage, CGImage, file paths, URLs)
  - Implements `@dynamicCallable` for simple inference API: `let results = model(image)`
  - Manages model loading, task detection, and predictor instantiation
- **Predictor Protocol** (Sources/YOLO/Predictor.swift): Base interface implemented by task-specific predictors
  - Defines common methods: `predict(image:)`, `predict(pixelBuffer:)`, `nms()`
- **Task-Specific Predictors**: ObjectDetector, Segmenter, Classifier, PoseEstimater, ObbDetector
  - Each handles its own postprocessing and NMS implementation
- **YOLOCamera/YOLOView**: SwiftUI and UIKit components for real-time camera inference
  - YOLOCamera (SwiftUI): High-level camera view with built-in model management
  - YOLOView (UIKit): Low-level camera view with customizable API

### Supported Tasks
- Object Detection (.detect) - Bounding boxes with class labels
- Image Segmentation (.segment) - Pixel-level masks with bounding boxes
- Classification (.classify) - Image-level class predictions
- Pose Estimation (.pose) - Keypoint detection for human pose
- Oriented Bounding Box Detection (.obb) - Rotated bounding boxes

### Model Integration
- Supports CoreML models (.mlmodel, .mlpackage, .mlmodelc)
- Models loaded from app bundle or file paths
- Automatic model type detection and appropriate predictor selection
- Vision framework integration for efficient image preprocessing

## Development Guidelines

### Model Requirements
- CoreML models must be YOLO-based and exported from Ultralytics Python package
- Detection models should include NMS layers (`nms=True` during export)
- Non-detection models use Swift-based NMS implementations
- Model export recommendations:
  - Use INT8 quantization for better mobile performance
  - Image sizes: [224, 224] for classification, [640, 384] for detection/segmentation
  - Only enable NMS for detection models, not for segment/pose/classify/obb tasks

### Model Export Examples
```python
# Detection model
model.export(format="coreml", imgsz=[640, 384], nms=True, int8=True)

# Classification model  
model.export(format="coreml", imgsz=[224, 224], nms=False, int8=True)

# Segmentation/Pose/OBB models
model.export(format="coreml", imgsz=[640, 384], nms=False, int8=True)
```

### Camera Integration
- Real-time features require physical iOS devices (not simulator)
- Add "Privacy - Camera Usage Description" to Info.plist for camera access
- Use YOLOCamera (SwiftUI) or YOLOView (UIKit) for camera integration

### Project Structure
- Swift Package supports iOS 16.0+, macOS 10.15+
- Example apps demonstrate both single-image and real-time inference patterns
- Each component includes comprehensive unit tests
- Model files supported: `.mlmodel`, `.mlpackage`, `.mlmodelc`
- Compiled `.mlmodelc` directories typically found within `.mlpackage` files

## Installation

### Swift Package Manager (Recommended)
1. In Xcode: `File > Add Packages...`
2. Enter package URL: `https://github.com/ultralytics/yolo-ios-app.git`
3. Select version and add to project

### Package.swift Dependency
```swift
dependencies: [
    .package(url: "https://github.com/ultralytics/yolo-ios-app.git", from: "1.0.0")
]
```

## External Display Support (Build 467+)

⚠️ **IMPORTANT**: This repository now includes external display support for presentations and demonstrations.

### Current Implementation Status
- ✅ Multi-scene architecture with Scene Delegates
- ✅ iPhone controls + External display visualization
- ✅ Dynamic UI scaling for 5K displays
- ✅ Model synchronization between displays
- ⚠️ Known issues with remote model loading
- ⚠️ UI synchronization timing issues

### Key Features
- **iPhone Controls**: All model selection and parameter adjustment
- **External Display**: Clean visualization with model name, FPS, and detection results
- **Dynamic Scaling**: Automatic UI scaling for large displays (Apple Studio Display 5K tested)
- **UI Toggle**: Eye button (👁️) to show/hide external display UI elements

### Technical Notes
- Uses `UIWindowSceneSessionRoleExternalDisplay` for external window management
- Scene Delegates handle multi-window coordination
- NotificationCenter for inter-scene communication
- YOLOView API methods made public: `switchCameraTapped()`, `sliderChanged()`

### Files Modified for External Display
- `YOLOiOSApp/Info.plist`: Multi-scene configuration
- `YOLOiOSApp/SceneDelegate.swift` & `ExternalSceneDelegate.swift`: Scene management
- `YOLOiOSApp/ExternalViewController.swift`: External display UI controller
- `YOLOiOSApp/ViewController.swift`: Main app with external display coordination
- `Sources/YOLO/YOLOView.swift`: Public API for external access
- `Sources/YOLO/BoundingBoxView.swift`: Dynamic scaling implementation

### Known Issues to Address
1. **Remote Model Loading**: Downloaded models may not sync properly to external display
2. **Initial Sync**: External display may not receive initial model state
3. **Performance**: Dual YOLOView instances need optimization
4. **Error Handling**: Better model loading failure management

### Testing Requirements
- Requires physical iOS device with external display capability
- Apple Studio Display (5K) recommended for testing
- Lightning to HDMI or USB-C display adapters

## Code Organization

### Project Structure Pattern
- Each app target has its own directory with `.xcodeproj` file
- Models organized by task type in dedicated directories (DetectModels/, SegmentModels/, etc.)
- Test files with `.backup` extension contain model-dependent tests
- Each test directory includes a README.md with setup instructions

### Code Style and Formatting
- Swift code follows standard iOS conventions
- No explicit SwiftFormat or SwiftLint configuration files (uses Xcode defaults)
- GitHub Actions uses Ultralytics formatter for consistency
- Test naming convention: `test<FeatureName>_<Scenario>_<ExpectedResult>()`

### Model File Management
- Model files (.mlpackage) contain CoreML models with weights
- Models are included in repository for easy app testing
- Remote model downloading supported via ModelDownloadManager
- Model files organized by task type: Detect, Segment, Classify, Pose, OBB

## License

- Open source: AGPL-3.0 License
- Commercial use: Enterprise License required (ultralytics.com/license)