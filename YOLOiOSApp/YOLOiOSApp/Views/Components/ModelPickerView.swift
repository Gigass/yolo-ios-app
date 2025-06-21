// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI
import YOLO

struct ModelPickerView: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var searchText = ""
    @State private var selectedTask: YOLOTask?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Select Model")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        viewModel.showModelPicker = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.ultralyticsSurfaceDark)
            
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Search models", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            // Task filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    TaskFilterChip(
                        title: "All",
                        isSelected: selectedTask == nil,
                        action: { selectedTask = nil }
                    )
                    
                    ForEach([YOLOTask.detect, .segment, .classify, .pose, .obb], id: \.self) { task in
                        TaskFilterChip(
                            title: task.displayName,
                            isSelected: selectedTask == task,
                            action: { selectedTask = task }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 12)
            
            // Model list
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(filteredModels, id: \.identifier) { model in
                        ModelRow(
                            model: model,
                            isSelected: viewModel.currentModel?.identifier == model.identifier,
                            isDownloaded: viewModel.downloadedModels.contains(model.identifier),
                            downloadProgress: viewModel.downloadProgress[model.identifier],
                            action: {
                                selectModel(model)
                            }
                        )
                    }
                }
                .background(Color.ultralyticsSurface)
            }
        }
        .background(Color.ultralyticsSurfaceDark)
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var filteredModels: [ModelInfo] {
        var models = viewModel.availableModels
        
        // Filter by task
        if let task = selectedTask {
            models = models.filter { $0.task == task }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            models = models.filter {
                $0.displayName.localizedCaseInsensitiveContains(searchText) ||
                $0.identifier.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return models
    }
    
    private func selectModel(_ model: ModelInfo) {
        if viewModel.downloadedModels.contains(model.identifier) {
            viewModel.selectModel(model)
            withAnimation(.easeOut(duration: 0.3)) {
                viewModel.showModelPicker = false
            }
        } else {
            viewModel.downloadModel(model)
        }
    }
}

struct TaskFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.ultralyticsLime : Color.gray.opacity(0.3))
                .clipShape(Capsule())
        }
    }
}

struct ModelRow: View {
    let model: ModelInfo
    let isSelected: Bool
    let isDownloaded: Bool
    let downloadProgress: Double?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Model icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.ultralyticsLime : Color.gray.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: model.task.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .black : .white)
                }
                
                // Model info
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label(model.task.displayName, systemImage: model.task.icon)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        Text(ModelSizeHelper.getModelSize(from: model.displayName))
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Capsule())
                    }
                }
                
                Spacer()
                
                // Download/status indicator
                if let progress = downloadProgress {
                    // Downloading
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(progress))
                            .stroke(Color.ultralyticsLime, lineWidth: 3)
                            .frame(width: 32, height: 32)
                            .rotationEffect(Angle(degrees: -90))
                        
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white)
                    }
                } else if isDownloaded {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.ultralyticsLime)
                    }
                } else {
                    Image(systemName: "arrow.down.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(isSelected ? Color.gray.opacity(0.1) : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Task icon extension
extension YOLOTask {
    var icon: String {
        switch self {
        case .detect:
            return "square.dashed"
        case .segment:
            return "scribble.variable"
        case .classify:
            return "tag"
        case .pose:
            return "figure.stand"
        case .obb:
            return "rotate.3d"
        }
    }
}