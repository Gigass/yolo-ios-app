// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var activeTool: Tool?
    
    // Sync with viewModel when parameter editor is dismissed externally
    var activeToolBinding: Binding<Tool?> {
        Binding(
            get: { 
                if viewModel.showParameterEditor, let param = viewModel.activeParameter {
                    return Tool.allCases.first { $0.parameter == param }
                }
                return nil
            },
            set: { _ in }
        )
    }
    
    enum Tool: Int, CaseIterable {
        case zoom = 0
        case itemsMax = 1
        case confidence = 2
        case iou = 3
        case lineThickness = 4
        
        var icon: String {
            switch self {
            case .zoom: return "" // Will show zoom level
            case .itemsMax: return "square.stack"
            case .confidence: return "chart.dots.scatter"
            case .iou: return "intersect.circle"
            case .lineThickness: return "pencil.line"
            }
        }
        
        var parameter: YOLOViewModel.ParameterType? {
            switch self {
            case .zoom: return nil
            case .itemsMax: return .maxDetections
            case .confidence: return .confidence
            case .iou: return .iou
            case .lineThickness: return .lineThickness
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Tool.allCases, id: \.self) { tool in
                if tool == .zoom {
                    ZoomButton(viewModel: viewModel)
                } else {
                    ToolButton(
                        tool: tool,
                        isActive: activeToolBinding.wrappedValue == tool,
                        action: {
                            toggleTool(tool)
                        }
                    )
                }
            }
        }
    }
    
    private func toggleTool(_ tool: Tool) {
        if activeTool == tool {
            // Tapping the same tool again closes it
            withAnimation(.easeInOut(duration: 0.2)) {
                activeTool = nil
                viewModel.showParameterEditor = false
                viewModel.activeParameter = nil
            }
        } else {
            // Switch to new tool
            withAnimation(.easeInOut(duration: 0.2)) {
                activeTool = tool
                viewModel.activeParameter = tool.parameter
                viewModel.showParameterEditor = true
            }
        }
    }
}

struct ZoomButton: View {
    @ObservedObject var viewModel: YOLOViewModel
    
    var body: some View {
        Button(action: {
            viewModel.cycleZoom()
        }) {
            Text(String(format: "%.1fx", viewModel.zoomLevel))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(viewModel.zoomLevel == 1.0 ? .white : .ultralyticsLime)
                .frame(width: 40, height: 40)
                .background(Color.ultralyticsBrown)
                .clipShape(Circle())
        }
    }
}

struct ToolButton: View {
    let tool: ToolbarView.Tool
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: tool.icon)
                .font(.system(size: 18))
                .foregroundColor(isActive ? .black : .white)
                .frame(width: 40, height: 40)
                .background(isActive ? Color.ultralyticsLime : Color.ultralyticsBrown)
                .clipShape(Circle())
        }
    }
}