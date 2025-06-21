// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI

struct StatusBar: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var showHiddenInfo = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Each element in equal width container
            Group {
                // Logo
                logoSection
                
                // Model selector
                modelSection
                
                // Model size
                sizeSection
                
                // FPS
                fpsSection
                
                // Latency
                latencySection
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 36)
        .background(Color.ultralyticsSurfaceDark)
        .sheet(isPresented: $showHiddenInfo) {
            HiddenInfoView()
        }
    }
    
    private var logoSection: some View {
        HStack {
            Spacer()
            Image("ultralytics_icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .onLongPressGesture(minimumDuration: 1.0) {
                    showHiddenInfo = true
                }
            Spacer()
        }
    }
    
    private var modelSection: some View {
        Button(action: {
            viewModel.showModelPicker.toggle()
        }) {
            HStack(spacing: 4) {
                Text(viewModel.currentModel?.displayName ?? "YOLO11")
                    .font(.statusBar)
                    .foregroundColor(.ultralyticsTextPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundColor(.ultralyticsTextPrimary)
            }
        }
    }
    
    private var sizeSection: some View {
        Text(modelSize)
            .font(.statusBar)
            .foregroundColor(.ultralyticsTextPrimary)
    }
    
    private var fpsSection: some View {
        Text(String(format: "%.1f FPS", viewModel.fps))
            .font(.statusBar)
            .foregroundColor(.ultralyticsTextPrimary)
    }
    
    private var latencySection: some View {
        Text(String(format: "%.1f ms", viewModel.latency))
            .font(.statusBar)
            .foregroundColor(.ultralyticsTextPrimary)
    }
    
    private var modelSize: String {
        guard let modelName = viewModel.currentModel?.displayName else { return "SMALL" }
        return ModelSizeHelper.getModelSize(from: modelName).uppercased()
    }
}

// Hidden info view
struct HiddenInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("ultralytics_splash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200)
                
                Text("Ultralytics YOLO")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version \(Bundle.main.appVersion)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Link("Visit ultralytics.com", destination: URL(string: "https://ultralytics.com")!)
                    .font(.body)
                    .foregroundColor(.ultralyticsLime)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// Typography extension
extension Font {
    static let statusBar = Font.system(size: 11, weight: .regular)
}

// Bundle extension for version
extension Bundle {
    var appVersion: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
}