// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = YOLOViewModel()
    
    var body: some View {
        // Always use SwiftUI ContentView
        ContentView(viewModel: viewModel)
    }
}

// Main content view with new SwiftUI design
struct ContentView: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var showSettings = false
    
    var body: some View {
        ZStack {
            Color.ultralyticsSurfaceDark
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Status Bar
                StatusBar(viewModel: viewModel)
                
                // Camera View with overlays
                ZStack {
                    YOLOCameraView(viewModel: viewModel)
                        .ignoresSafeArea(edges: [.horizontal])
                    
                    // Right toolbar overlay
                    HStack {
                        Spacer()
                        ToolbarView(viewModel: viewModel)
                            .padding(.trailing, 12)
                    }
                    
                    // Parameter editor overlay
                    if viewModel.showParameterEditor {
                        ParameterEditorView(viewModel: viewModel)
                            .transition(.opacity)
                    }
                }
                
                // Task tabs
                TaskTabsView(selectedTask: $viewModel.currentTask)
                    .onChange(of: viewModel.currentTask) { newTask in
                        viewModel.switchTask(newTask)
                    }
                
                // Shutter bar
                ShutterBarView(viewModel: viewModel)
            }
            
            // Model picker overlay
            if viewModel.showModelPicker {
                ModelPickerView(viewModel: viewModel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showModelPicker)
        .animation(.easeInOut(duration: 0.2), value: viewModel.showParameterEditor)
    }
}

// Wrapper for legacy UIViewController
struct LegacyViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController() as! ViewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // No updates needed
    }
}