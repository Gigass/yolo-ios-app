# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

### Swift Package Commands
```bash
# Resolve Swift Package dependencies
xcodebuild -resolvePackageDependencies

# Build the Swift Package
xcodebuild -scheme YOLO -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 14" build

# Run tests with coverage
xcodebuild \
  -scheme YOLO \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone 14" \
  -enableCodeCoverage YES \
  clean build test

# Download test models (required for full test suite)
chmod +x Tests/YOLOTests/Resources/download-test-models.sh
Tests/YOLOTests/Resources/download-test-models.sh
```

### iOS App Commands
```bash
# Build YOLOiOSApp target
xcodebuild -scheme YOLOiOSApp -sdk iphonesimulator build

# Build example apps
xcodebuild -scheme YOLORealTimeSwiftUI -sdk iphonesimulator build
xcodebuild -scheme YOLORealTimeUIKit -sdk iphonesimulator build
```

## Architecture Overview

### Repository Structure
- **Sources/YOLO/**: Swift Package containing the YOLO library
  - Core protocols: `Predictor` protocol defines the interface for all YOLO tasks
  - Task-specific predictors: ObjectDetector, Classifier, Segmenter, PoseEstimater, ObbDetector
  - UI components: YOLOView, YOLOCamera, BoundingBoxView
  - Utilities: VideoCapture, NonMaxSuppression, ThresholdProvider

- **YOLOiOSApp/**: Main iOS application demonstrating YOLO capabilities
  - Contains pre-trained CoreML models organized by task type
  - Supports drag-and-drop of custom CoreML models

- **ExampleApps/**: Four example implementations showing different use cases
  - Real-time detection with SwiftUI and UIKit
  - Single image processing with SwiftUI and UIKit

### Key Design Patterns

1. **Protocol-Based Architecture**: The `Predictor` protocol provides a unified interface for all YOLO tasks, enabling polymorphic usage across different model types.

2. **Callable Syntax**: The YOLO class implements Swift's callable syntax, allowing intuitive model inference:
   ```swift
   let result = model(image)  // Direct call syntax
   ```

3. **Multi-Input Support**: Models accept various input types (UIImage, CIImage, CGImage, SwiftUI.Image, file paths, URLs) through protocol extensions and type conversions.

4. **Task-Specific Results**: Each predictor returns task-appropriate result types (DetectionResult, ClassificationResult, etc.) with structured data for easy consumption.

5. **Real-Time Processing**: YOLOCamera view handles AVFoundation integration, frame capture, and result visualization in a declarative SwiftUI component.

## Testing Strategy

- Tests require CoreML models which can be downloaded via the provided script
- Use `SKIP_MODEL_TESTS = true` in test files to run tests without models
- Test coverage includes unit tests for all major components and integration tests
- CI runs on macOS-15 with automatic model downloads

## Code Style Guidelines

- Follow standard Swift conventions (2-space indentation, camelCase naming)
- All files must include Ultralytics license header
- Use `///` documentation comments for public APIs
- Import order: system frameworks, then custom modules
- Prefer SwiftUI for new UI components
- Use structured concurrency (async/await) for asynchronous operations