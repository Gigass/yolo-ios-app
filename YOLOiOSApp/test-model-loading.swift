// Test script to verify model loading
import Foundation

// Check if DetectModels folder exists in bundle
if let detectModelsURL = Bundle.main.url(forResource: "DetectModels", withExtension: nil) {
    print("✅ DetectModels folder found in bundle")
    
    // List all files in the folder
    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: detectModelsURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )
        
        print("\nFiles in DetectModels:")
        for fileURL in fileURLs {
            print("  - \(fileURL.lastPathComponent)")
        }
        
        let modelFiles = fileURLs.filter { 
            $0.pathExtension == "mlmodel" || $0.pathExtension == "mlpackage" 
        }
        
        print("\nModel files found: \(modelFiles.count)")
        for model in modelFiles {
            print("  📦 \(model.lastPathComponent)")
        }
        
    } catch {
        print("❌ Error reading DetectModels folder: \(error)")
    }
} else {
    print("❌ DetectModels folder not found in bundle")
}