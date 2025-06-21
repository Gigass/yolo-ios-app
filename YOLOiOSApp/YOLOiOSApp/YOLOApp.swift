// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI
import YOLO

@main
struct YOLOApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Set global app settings that were in AppDelegate
        UIApplication.shared.isIdleTimerDisabled = true
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Store app version and device info
        let versionKey = "app_version"
        let previousVersion = UserDefaults.standard.string(forKey: versionKey)
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            UserDefaults.standard.set(currentVersion, forKey: versionKey)
            if previousVersion == nil {
                print("First launch of app version \(currentVersion)")
            } else if previousVersion != currentVersion {
                print("App updated from \(previousVersion ?? "unknown") to \(currentVersion)")
            }
        }
        
        // Store device UUID
        let uuid = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        UserDefaults.standard.set(uuid, forKey: "device_uuid")
        
        // Debug: Check bundle resources
        debugBundleResources()
    }
    
    private func debugBundleResources() {
        print("=== Debugging Bundle Resources ===")
        
        // Check for individual models
        let testModels = ["yolo11n", "yolo11s", "yolo11n-seg", "yolo11n-cls", "yolo11n-pose", "yolo11n-obb"]
        for model in testModels {
            if let url = Bundle.main.url(forResource: model, withExtension: "mlpackage") {
                print("✅ Found \(model) at: \(url.path)")
            } else {
                print("❌ \(model).mlpackage not found")
            }
        }
        
        // Check for model folders
        let folders = ["DetectModels", "SegmentModels", "ClassifyModels", "PoseModels", "OBBModels"]
        for folder in folders {
            if let url = Bundle.main.url(forResource: folder, withExtension: nil) {
                print("✅ Found folder \(folder) at: \(url.path)")
                
                // List contents
                do {
                    let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                    for file in contents {
                        print("   - \(file.lastPathComponent)")
                    }
                } catch {
                    print("   ❌ Error reading folder: \(error)")
                }
            } else {
                print("❌ Folder \(folder) not found")
            }
        }
        
        print("=================================")
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .preferredColorScheme(.dark)
                .onAppear {
                    // Force SwiftUI mode
                    appState.isNewUIActive = true
                }
        }
    }
}

// Global app state
class AppState: ObservableObject {
    @Published var isNewUIActive = true // For gradual migration
    @Published var showDebugInfo = false
    
    // Settings persistence
    @AppStorage("confidenceThreshold") var confidenceThreshold: Double = 0.25
    @AppStorage("iouThreshold") var iouThreshold: Double = 0.45
    @AppStorage("maxDetections") var maxDetections: Int = 300
}