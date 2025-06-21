// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI
import YOLO
import UIKit
import AVFoundation

struct YOLOCameraView: UIViewRepresentable {
    @ObservedObject var viewModel: YOLOViewModel
    
    func makeUIView(context: Context) -> YOLOView {
        // Create YOLOView with initial model and task
        // Get default model path if no model is selected
        let defaultPath: String
        if let detectModelsURL = Bundle.main.url(forResource: "DetectModels", withExtension: nil),
           let yolo11nURL = detectModelsURL.appendingPathComponent("yolo11n.mlpackage") as URL?,
           FileManager.default.fileExists(atPath: yolo11nURL.path) {
            defaultPath = yolo11nURL.path
        } else {
            // Fallback to just the name, though this will likely fail
            defaultPath = "yolo11n"
        }
        
        let modelPath = viewModel.currentModel?.identifier ?? defaultPath
        
        // Note: YOLOView requires a model path in init, even if the model doesn't exist
        // It will crash if model is not found - this needs to be fixed in YOLO package
        let yoloView = YOLOView(
            frame: .zero,
            modelPathOrName: modelPath,
            task: viewModel.currentTask
        )
        
        // Set delegate
        yoloView.delegate = context.coordinator
        
        // Hide built-in UI controls since we're using SwiftUI
        yoloView.sliderConf.isHidden = true
        yoloView.sliderIoU.isHidden = true
        yoloView.sliderNumItems.isHidden = true
        yoloView.labelSliderConf.isHidden = true
        yoloView.labelSliderIoU.isHidden = true
        yoloView.labelSliderNumItems.isHidden = true
        
        // Set initial parameters
        yoloView.sliderConf.value = viewModel.confidenceThreshold
        yoloView.sliderIoU.value = viewModel.iouThreshold
        yoloView.sliderNumItems.value = Float(viewModel.maxDetections)
        
        return yoloView
    }
    
    func updateUIView(_ uiView: YOLOView, context: Context) {
        // Update model if changed
        if let model = viewModel.currentModel,
           uiView.currentModelName != model.identifier {
            uiView.setModel(modelPathOrName: model.identifier, task: viewModel.currentTask)
        }
        
        // Update zoom level
        uiView.setZoomLevel(viewModel.zoomLevel)
        
        // Update detection parameters
        uiView.sliderConf.value = viewModel.confidenceThreshold
        uiView.sliderIoU.value = viewModel.iouThreshold
        uiView.sliderNumItems.value = Float(viewModel.maxDetections)
        
        // Update inference state
        uiView.setInferenceFlag(ok: !viewModel.isModelLoading)
        
        // Handle recording state
        context.coordinator.handleRecordingState(viewModel.isRecording, yoloView: uiView)
        
        // Handle photo capture
        if viewModel.captureRequested {
            context.coordinator.capturePhotoIfNeeded(uiView)
            viewModel.captureRequested = false
        }
        
        // Handle camera switching
        if let videoCapture = uiView.value(forKey: "videoCapture") as? NSObject,
           let switchButton = uiView.value(forKey: "switchCameraButton") as? UIButton {
            // Trigger camera switch if position changed
            let currentPosition = videoCapture.value(forKey: "cameraPosition") as? AVCaptureDevice.Position
            if currentPosition != viewModel.cameraPosition {
                switchButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }
    
    class Coordinator: NSObject, YOLOViewDelegate {
        let viewModel: YOLOViewModel
        var shouldCapturePhoto = false
        var isRecording = false
        
        init(viewModel: YOLOViewModel) {
            self.viewModel = viewModel
            super.init()
        }
        
        // MARK: - YOLOViewDelegate
        
        func yoloView(_ view: YOLOView, didUpdatePerformance fps: Double, inferenceTime: Double) {
            Task { @MainActor in
                viewModel.updatePerformance(fps: fps, latency: inferenceTime)
            }
        }
        
        func yoloView(_ view: YOLOView, didReceiveResult result: YOLOResult) {
            Task { @MainActor in
                viewModel.processResult(result)
            }
        }
        
        // MARK: - Camera Actions
        
        func handleRecordingState(_ isRecording: Bool, yoloView: YOLOView) {
            if isRecording != self.isRecording {
                self.isRecording = isRecording
                // TODO: Implement recording functionality
                // The YOLOView doesn't expose recording functionality directly
                // This would need to be implemented through VideoCapture or a custom solution
            }
        }
        
        func capturePhotoIfNeeded(_ yoloView: YOLOView) {
            if shouldCapturePhoto {
                shouldCapturePhoto = false
                Task { @MainActor in
                    yoloView.capturePhoto { [weak self] image in
                        self?.viewModel.capturedImage = image
                        self?.viewModel.lastThumbnail = image
                    }
                }
            }
        }
    }
}

// MARK: - Bridge Extensions

extension YOLOView {
    var currentModelName: String? {
        // This would need to be exposed in YOLOView
        // For now, return nil to force model updates
        return nil
    }
}