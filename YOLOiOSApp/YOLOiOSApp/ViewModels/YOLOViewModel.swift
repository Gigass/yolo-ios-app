// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI
import Combine
import YOLO
import UIKit
import AVFoundation

// Model info type
struct ModelInfo: Identifiable {
    let id = UUID()
    let identifier: String
    let displayName: String
    let task: YOLOTask
    let isRemote: Bool
    let isLocalBundle: Bool
    
    init(from entry: ModelEntry) {
        self.identifier = entry.identifier
        self.displayName = entry.displayName
        self.isRemote = entry.isRemote
        self.isLocalBundle = entry.isLocalBundle
        
        // Determine task from entry.task string
        switch entry.task {
        case "Detect": self.task = .detect
        case "Segment": self.task = .segment
        case "Classify": self.task = .classify
        case "Pose": self.task = .pose
        case "OBB": self.task = .obb
        default: self.task = .detect
        }
    }
}

@MainActor
class YOLOViewModel: ObservableObject {
    // MARK: - Model Management
    @Published var currentModel: ModelInfo?
    @Published var availableModels: [ModelInfo] = []
    @Published var currentTask: YOLOTask = .detect
    @Published var isModelLoading = false
    @Published var modelLoadError: String?
    
    // MARK: - Performance Metrics
    @Published var fps: Double = 0.0
    @Published var latency: Double = 0.0
    
    // MARK: - Detection Results
    @Published var detectionResults: [Detection] = []
    @Published var isProcessing = false
    
    // MARK: - Camera Controls
    @Published var zoomLevel: Float = 1.0
    @Published var isRecording = false
    @Published var capturedImage: UIImage?
    @Published var lastThumbnail: UIImage?
    @Published var captureRequested = false
    @Published var cameraPosition: AVCaptureDevice.Position = .back
    
    // MARK: - Detection Parameters
    @Published var confidenceThreshold: Float = 0.25 {
        didSet { UserDefaults.standard.set(confidenceThreshold, forKey: "confidenceThreshold") }
    }
    @Published var iouThreshold: Float = 0.45 {
        didSet { UserDefaults.standard.set(iouThreshold, forKey: "iouThreshold") }
    }
    @Published var maxDetections: Int = 300 {
        didSet { UserDefaults.standard.set(maxDetections, forKey: "maxDetections") }
    }
    @Published var lineThickness: Float = 2.0 {
        didSet { UserDefaults.standard.set(lineThickness, forKey: "lineThickness") }
    }
    
    // MARK: - UI State
    @Published var showModelPicker = false
    @Published var showParameterEditor = false
    @Published var activeParameter: ParameterType?
    @Published var isVideoMode = false
    @Published var downloadedModels: Set<String> = []
    @Published var downloadProgress: [String: Double] = [:]
    
    enum ParameterType {
        case confidence, iou, maxDetections, lineThickness
        
        var title: String {
            switch self {
            case .confidence: return "Confidence Threshold"
            case .iou: return "IoU Threshold"
            case .maxDetections: return "Max Detections"
            case .lineThickness: return "Line Thickness"
            }
        }
        
        var label: String {
            switch self {
            case .confidence: return "Confidence"
            case .iou: return "IoU"
            case .maxDetections: return "Max Items"
            case .lineThickness: return "Line Width"
            }
        }
        
        var range: ClosedRange<Float> {
            switch self {
            case .confidence, .iou: return 0...1
            case .maxDetections: return 1...500
            case .lineThickness: return 1...10
            }
        }
        
        var step: Float {
            switch self {
            case .confidence, .iou: return 0.01
            case .maxDetections: return 1
            case .lineThickness: return 0.5
            }
        }
        
        var presets: [Float] {
            switch self {
            case .confidence: return [0.25, 0.50, 0.75]
            case .iou: return [0.45, 0.60, 0.75]
            case .maxDetections: return [50, 100, 300]
            case .lineThickness: return [1, 2, 4]
            }
        }
    }
    
    // Model cache manager
    private let modelCache = ModelCacheManager.shared
    
    init() {
        loadUserDefaults()
        loadAvailableModels()
    }
    
    // MARK: - Model Management
    
    func loadAvailableModels() {
        // Load models for current task
        let taskName = currentTask.displayName
        let entries = makeModelEntries(for: taskName)
        availableModels = entries.map { ModelInfo(from: $0) }
        
        // Mark downloaded models
        for model in availableModels {
            if model.isLocalBundle {
                downloadedModels.insert(model.identifier)
            } else {
                // Check if model exists in documents directory
                let modelURL = getDocumentsDirectory()
                    .appendingPathComponent(model.identifier)
                    .appendingPathExtension("mlmodelc")
                if FileManager.default.fileExists(atPath: modelURL.path) {
                    downloadedModels.insert(model.identifier)
                }
            }
        }
        
        // Select first model if none selected
        if currentModel == nil && !availableModels.isEmpty {
            selectModel(availableModels[0])
        }
    }
    
    func selectModel(_ model: ModelInfo) {
        guard model.identifier != currentModel?.identifier else { return }
        
        isModelLoading = true
        currentModel = model
        
        // Model loading will be handled by YOLOView
        // This is just for UI state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isModelLoading = false
        }
    }
    
    func switchTask(_ task: YOLOTask) {
        currentTask = task
        loadAvailableModels()
    }
    
    // MARK: - Camera Actions
    
    func capturePhoto() {
        captureRequested = true
    }
    
    func toggleRecording() {
        isRecording.toggle()
        print("Recording: \(isRecording)")
    }
    
    func switchCamera() {
        // Toggle camera position
        cameraPosition = (cameraPosition == .back) ? .front : .back
    }
    
    func toggleCaptureMode() {
        isVideoMode.toggle()
    }
    
    func processSelectedImage(_ image: UIImage) {
        // Process image from gallery
        capturedImage = image
        lastThumbnail = image
    }
    
    func downloadModel(_ model: ModelInfo) {
        guard !downloadedModels.contains(model.identifier) else { return }
        
        // Simulate download
        downloadProgress[model.identifier] = 0.0
        
        // In real implementation, this would download the model
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            Task { @MainActor in
                let currentProgress = self.downloadProgress[model.identifier] ?? 0.0
                if currentProgress < 1.0 {
                    self.downloadProgress[model.identifier] = min(currentProgress + 0.1, 1.0)
                } else {
                    timer.invalidate()
                    self.downloadedModels.insert(model.identifier)
                    self.downloadProgress.removeValue(forKey: model.identifier)
                    self.selectModel(model)
                }
            }
        }
    }
    
    func cycleZoom() {
        let levels: [Float] = [0.5, 1.0, 3.0]
        if let currentIndex = levels.firstIndex(where: { abs($0 - zoomLevel) < 0.1 }) {
            let nextIndex = (currentIndex + 1) % levels.count
            zoomLevel = levels[nextIndex]
        } else {
            zoomLevel = 1.0
        }
    }
    
    // MARK: - Performance Updates
    
    func updatePerformance(fps: Double, latency: Double) {
        self.fps = fps
        self.latency = latency
    }
    
    // MARK: - Detection Results
    
    func processResult(_ result: YOLOResult) {
        // Convert YOLOResult to our Detection model
        // This will be implemented when we create the Detection model
    }
    
    // MARK: - Private Helpers
    
    private func loadUserDefaults() {
        confidenceThreshold = UserDefaults.standard.float(forKey: "confidenceThreshold", defaultValue: 0.25)
        iouThreshold = UserDefaults.standard.float(forKey: "iouThreshold", defaultValue: 0.45)
        maxDetections = UserDefaults.standard.integer(forKey: "maxDetections", defaultValue: 300)
    }
    
    private func makeModelEntries(for taskName: String) -> [ModelEntry] {
        var entries: [ModelEntry] = []
        
        // Get folder name for the task
        let folderName = "\(taskName)Models"
        
        // Scan for local models in the bundle
        if let folderURL = Bundle.main.url(forResource: folderName, withExtension: nil) {
            let localModels = getModelFiles(in: folderName)
            for modelFileName in localModels {
                let modelName = URL(fileURLWithPath: modelFileName).deletingPathExtension().lastPathComponent
                let modelPath = folderURL.appendingPathComponent(modelFileName).path
                print("Found model: \(modelName) at path: \(modelPath)")
                entries.append(ModelEntry(
                    identifier: modelPath,  // Use full path for YOLOView
                    displayName: modelName,
                    task: taskName,
                    isRemote: false,
                    isLocalBundle: true
                ))
            }
        }
        
        // Add remote models
        let remoteModels = RemoteModelRegistry.models(for: taskName)
        entries.append(contentsOf: remoteModels)
        
        return entries
    }
    
    private func getModelFiles(in folderName: String) -> [String] {
        guard let folderURL = Bundle.main.url(forResource: folderName, withExtension: nil) else {
            print("Folder not found: \(folderName)")
            return []
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: folderURL,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            )
            
            // Filter for .mlpackage files and return just the filenames
            return fileURLs.compactMap { url in
                if url.pathExtension == "mlpackage" {
                    // Return just the filename, not the full path
                    return url.lastPathComponent
                }
                return nil
            }
        } catch {
            print("Error reading folder contents: \(error)")
            return []
        }
    }
    
    private func taskSuffix(for taskName: String) -> String {
        switch taskName {
        case "Detect": return ""
        case "Segment": return "seg"
        case "Classify": return "cls"
        case "Pose": return "pose"
        case "OBB": return "obb"
        default: return ""
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// MARK: - Supporting Types

struct Detection: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Float
    let boundingBox: CGRect
    let color: Color
}

extension YOLOTask {
    var displayName: String {
        switch self {
        case .detect: return "Detect"
        case .segment: return "Segment"
        case .classify: return "Classify"
        case .pose: return "Pose"
        case .obb: return "OBB"
        }
    }
}

extension UserDefaults {
    func float(forKey key: String, defaultValue: Float) -> Float {
        if object(forKey: key) != nil {
            return float(forKey: key)
        }
        return defaultValue
    }
    
    func integer(forKey key: String, defaultValue: Int) -> Int {
        if object(forKey: key) != nil {
            return integer(forKey: key)
        }
        return defaultValue
    }
}