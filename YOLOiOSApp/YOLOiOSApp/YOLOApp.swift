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