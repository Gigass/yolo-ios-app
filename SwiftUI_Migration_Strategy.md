# SwiftUI Migration Strategy for YOLO iOS App

## Executive Summary

This document outlines a comprehensive strategy to migrate the YOLO iOS app from UIKit to SwiftUI. The migration will be executed in phases to ensure app stability while modernizing the codebase.

## Current Architecture Overview

### UIKit Components
1. **ViewController.swift** - Main view controller (1200+ lines)
2. **YOLOView** - Camera and detection view (UIView + AVFoundation)
3. **Custom UI Components**:
   - StatusMetricBar
   - TaskTabStrip  
   - ShutterBar
   - RightSideToolBar
   - ParameterEditView
   - ModelDropdownView

### Dependencies
- Storyboard for initial setup
- CALayer for detection rendering
- UIGestureRecognizer for interactions
- AVFoundation for camera management

## Migration Strategy

### Phase 1: Foundation Setup (Week 1-2)

#### 1.1 Create SwiftUI App Structure
```swift
// App.swift
@main
struct YOLOApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
        }
    }
}
```

#### 1.2 Implement Core View Models
```swift
// ViewModels/YOLOViewModel.swift
@MainActor
class YOLOViewModel: ObservableObject {
    @Published var currentModel: ModelEntry?
    @Published var currentTask: YOLOTask = .detect
    @Published var fps: Double = 0.0
    @Published var latency: Double = 0.0
    @Published var isProcessing = false
    @Published var detectionResults: [Detection] = []
    
    // Camera controls
    @Published var zoomLevel: Float = 1.0
    @Published var isRecording = false
    @Published var capturedImage: UIImage?
    
    // Parameters
    @Published var confidenceThreshold: Float = 0.25
    @Published var iouThreshold: Float = 0.45
    @Published var maxDetections: Int = 300
}
```

#### 1.3 Create UIViewRepresentable for YOLOView
```swift
// Views/Camera/YOLOCameraView.swift
struct YOLOCameraView: UIViewRepresentable {
    @ObservedObject var viewModel: YOLOViewModel
    
    func makeUIView(context: Context) -> YOLOView {
        let yoloView = YOLOView(frame: .zero, 
                               modelPathOrName: viewModel.currentModel?.path ?? "",
                               task: viewModel.currentTask)
        yoloView.delegate = context.coordinator
        return yoloView
    }
    
    func updateUIView(_ uiView: YOLOView, context: Context) {
        // Update model/task when changed
        if let model = viewModel.currentModel {
            uiView.setModel(modelPathOrName: model.path, task: viewModel.currentTask)
        }
        uiView.setZoomLevel(viewModel.zoomLevel)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, YOLOViewDelegate {
        let viewModel: YOLOViewModel
        
        init(viewModel: YOLOViewModel) {
            self.viewModel = viewModel
        }
        
        func yoloView(_ view: YOLOView, didUpdatePerformanceInfo fps: Double, latency: Double) {
            viewModel.fps = fps
            viewModel.latency = latency
        }
    }
}
```

### Phase 2: UI Component Migration (Week 2-3)

#### 2.1 Status Bar (Pure SwiftUI)
```swift
// Views/Components/StatusBar.swift
struct StatusBar: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var showModelPicker = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Logo
            Image("ultralytics_icon")
                .resizable()
                .frame(width: 20, height: 20)
                .onLongPressGesture {
                    // Show hidden info
                }
            
            Spacer()
            
            // Model button
            Button(action: { showModelPicker.toggle() }) {
                HStack(spacing: 4) {
                    Text(viewModel.currentModel?.displayName ?? "YOLO11")
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
            }
            .foregroundColor(.ultralyticsTextPrimary)
            
            Spacer()
            
            // Metrics
            Text(viewModel.currentModel?.size ?? "SMALL")
            Spacer()
            Text(String(format: "%.1f FPS", viewModel.fps))
            Spacer()
            Text(String(format: "%.1f ms", viewModel.latency))
        }
        .padding(.horizontal)
        .frame(height: 36)
        .background(Color.ultralyticsSurfaceDark)
        .sheet(isPresented: $showModelPicker) {
            ModelPickerView(viewModel: viewModel)
        }
    }
}
```

#### 2.2 Task Tabs (SwiftUI with Scroll)
```swift
// Views/Components/TaskTabsView.swift
struct TaskTabsView: View {
    @Binding var selectedTask: YOLOTask
    let tasks: [YOLOTask] = [.detect, .segment, .classify, .pose, .obb]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(tasks, id: \.self) { task in
                    TaskTab(
                        task: task,
                        isSelected: selectedTask == task,
                        action: { selectedTask = task }
                    )
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 28)
        .background(Color.ultralyticsSurfaceDark)
    }
}

struct TaskTab: View {
    let task: YOLOTask
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(task.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .ultralyticsLime : .ultralyticsTextSubtle)
                
                Rectangle()
                    .fill(Color.ultralyticsLime)
                    .frame(height: 2)
                    .opacity(isSelected ? 1 : 0)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
```

#### 2.3 Right Toolbar
```swift
// Views/Components/ToolbarView.swift
struct ToolbarView: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var activeTool: Tool?
    
    enum Tool: String, CaseIterable {
        case zoom, itemsMax, confidence, iou, lineThickness
        
        var icon: String {
            switch self {
            case .zoom: return "" // Will show zoom level
            case .itemsMax: return "square.stack"
            case .confidence: return "chart.dots.scatter"
            case .iou: return "intersect.circle"
            case .lineThickness: return "pencil.line"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Zoom button
            Button(action: cycleZoom) {
                Text(String(format: "%.1fx", viewModel.zoomLevel))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(viewModel.zoomLevel == 1.0 ? .white : .ultralyticsLime)
            }
            .frame(width: 40, height: 40)
            .background(Color.ultralyticsBrown)
            .clipShape(Circle())
            
            // Other tools
            ForEach(Tool.allCases.filter { $0 != .zoom }, id: \.self) { tool in
                ToolButton(
                    tool: tool,
                    isActive: activeTool == tool,
                    action: { toggleTool(tool) }
                )
            }
        }
    }
    
    private func cycleZoom() {
        let levels: [Float] = [0.5, 1.0, 3.0]
        if let currentIndex = levels.firstIndex(where: { abs($0 - viewModel.zoomLevel) < 0.1 }) {
            let nextIndex = (currentIndex + 1) % levels.count
            viewModel.zoomLevel = levels[nextIndex]
        }
    }
}
```

### Phase 3: Complex Components Migration (Week 3-4)

#### 3.1 Model Picker (SwiftUI Sheet)
```swift
// Views/Components/ModelPickerView.swift
struct ModelPickerView: View {
    @ObservedObject var viewModel: YOLOViewModel
    @Environment(\.dismiss) var dismiss
    
    var groupedModels: [(String, [ModelEntry])] {
        // Group logic here
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(groupedModels, id: \.0) { section in
                    Section(header: Text(section.0)) {
                        ForEach(section.1) { model in
                            ModelRow(
                                model: model,
                                isSelected: viewModel.currentModel?.id == model.id,
                                onSelect: {
                                    viewModel.selectModel(model)
                                    dismiss()
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Select Model")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
```

#### 3.2 Parameter Controls
```swift
// Views/Components/ParameterControlsView.swift
struct ParameterControlsView: View {
    @ObservedObject var viewModel: YOLOViewModel
    let parameter: RightSideToolBar.Tool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(parameter.title)
                .font(.headline)
            
            HStack {
                Text(parameter.minLabel)
                Slider(value: binding(for: parameter), 
                       in: parameter.range)
                    .accentColor(.ultralyticsLime)
                Text(parameter.maxLabel)
            }
            
            Text(currentValueText)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.ultralyticsSurfaceDark)
        .cornerRadius(12)
    }
}
```

### Phase 4: Camera and Detection Overlay (Week 4-5)

#### 4.1 Detection Overlay
```swift
// Views/Camera/DetectionOverlay.swift
struct DetectionOverlay: View {
    let detections: [Detection]
    let imageSize: CGSize
    let viewSize: CGSize
    
    var body: some View {
        Canvas { context, size in
            let scale = min(size.width / imageSize.width, 
                          size.height / imageSize.height)
            
            for detection in detections {
                let rect = detection.boundingBox
                    .scaled(by: scale)
                    .centered(in: size)
                
                // Draw bounding box
                context.stroke(
                    Path(rect),
                    with: .color(detection.color),
                    lineWidth: 2
                )
                
                // Draw label
                context.draw(
                    Text(detection.label)
                        .font(.caption)
                        .foregroundColor(.white),
                    at: CGPoint(x: rect.minX + 5, y: rect.minY + 5)
                )
            }
        }
    }
}
```

### Phase 5: Final Integration (Week 5-6)

#### 5.1 Remove UIKit Dependencies
- Remove Main.storyboard
- Update Info.plist
- Remove UIViewController code
- Clean up delegates

#### 5.2 Performance Optimization
- Profile with Instruments
- Optimize Canvas rendering
- Minimize view updates
- Implement lazy loading

#### 5.3 Testing & Polish
- Unit tests for ViewModels
- UI tests for interactions
- Performance benchmarks
- Accessibility audit

## Migration Checklist

- [ ] Phase 1: Foundation
  - [ ] Create SwiftUI app structure
  - [ ] Implement ViewModels
  - [ ] Create YOLOView wrapper
  
- [ ] Phase 2: UI Components
  - [ ] StatusBar
  - [ ] TaskTabs
  - [ ] Toolbar
  - [ ] ShutterBar
  
- [ ] Phase 3: Complex Components
  - [ ] ModelPicker
  - [ ] ParameterControls
  - [ ] LoadingOverlay
  
- [ ] Phase 4: Camera Integration
  - [ ] Detection overlay
  - [ ] Gesture handling
  - [ ] Recording support
  
- [ ] Phase 5: Finalization
  - [ ] Remove UIKit code
  - [ ] Performance optimization
  - [ ] Testing & documentation

## Risk Mitigation

1. **Performance Risk**: Keep YOLOView as UIViewRepresentable initially
2. **Compatibility Risk**: Use @available checks for newer APIs
3. **Feature Parity Risk**: Create comprehensive test suite
4. **User Experience Risk**: A/B test if possible

## Timeline

- **Total Duration**: 5-6 weeks
- **Team Size**: 1-2 iOS developers
- **Review Points**: End of each phase

## Success Metrics

1. Maintain 60 FPS during inference
2. Reduce code complexity by 30%
3. Improve testability to 80% coverage
4. Maintain all current features
5. Support iOS 14+

## Conclusion

This phased approach allows for incremental migration while maintaining app stability. The hybrid approach (UIViewRepresentable for YOLOView) ensures performance while modernizing the UI layer.