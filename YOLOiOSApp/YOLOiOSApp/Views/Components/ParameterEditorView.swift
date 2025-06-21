// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI

struct ParameterEditorView: View {
    @ObservedObject var viewModel: YOLOViewModel
    
    var body: some View {
        ZStack {
            // Tap outside to dismiss
            if viewModel.showParameterEditor {
                Color.black.opacity(0.01)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.showParameterEditor = false
                            viewModel.activeParameter = nil
                        }
                    }
            }
            
            if let parameter = viewModel.activeParameter {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 0) {
                        // Drag indicator
                        RoundedRectangle(cornerRadius: 2.5)
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                        
                        // Parameter content
                        VStack(spacing: 20) {
                            // Title and value
                            HStack {
                                Text(parameter.label)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text(formattedValue(for: parameter))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.ultralyticsLime)
                            }
                            .padding(.horizontal, 24)
                            
                            // Slider with tick marks
                            TickMarkSlider(
                                value: binding(for: parameter),
                                parameter: parameter
                            )
                            .padding(.horizontal, 24)
                            
                            // Quick presets
                            if !parameter.presets.isEmpty {
                                HStack(spacing: 12) {
                                    ForEach(parameter.presets, id: \.self) { preset in
                                        Button(action: {
                                            withAnimation(.easeOut(duration: 0.1)) {
                                                setValue(preset, for: parameter)
                                            }
                                        }) {
                                            Text(formatPresetLabel(preset, for: parameter))
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(
                                                    abs(getValue(for: parameter) - preset) < 0.01 ? .black : .white
                                                )
                                                .padding(.horizontal, 16)
                                                .padding(.vertical, 8)
                                                .background(
                                                    abs(getValue(for: parameter) - preset) < 0.01 ?
                                                    Color.ultralyticsLime : Color.gray.opacity(0.3)
                                                )
                                                .clipShape(Capsule())
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.bottom, 24)
                    }
                    .background(Color.ultralyticsSurface)
                    .cornerRadius(20, corners: [.topLeft, .topRight])
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
    
    private func binding(for parameter: YOLOViewModel.ParameterType) -> Binding<Float> {
        switch parameter {
        case .confidence:
            return $viewModel.confidenceThreshold
        case .iou:
            return $viewModel.iouThreshold
        case .maxDetections:
            return Binding(
                get: { Float(viewModel.maxDetections) },
                set: { viewModel.maxDetections = Int($0) }
            )
        case .lineThickness:
            return $viewModel.lineThickness
        }
    }
    
    private func getValue(for parameter: YOLOViewModel.ParameterType) -> Float {
        switch parameter {
        case .confidence:
            return viewModel.confidenceThreshold
        case .iou:
            return viewModel.iouThreshold
        case .maxDetections:
            return Float(viewModel.maxDetections)
        case .lineThickness:
            return viewModel.lineThickness
        }
    }
    
    private func setValue(_ value: Float, for parameter: YOLOViewModel.ParameterType) {
        switch parameter {
        case .confidence:
            viewModel.confidenceThreshold = value
        case .iou:
            viewModel.iouThreshold = value
        case .maxDetections:
            viewModel.maxDetections = Int(value)
        case .lineThickness:
            viewModel.lineThickness = value
        }
    }
    
    private func formattedValue(for parameter: YOLOViewModel.ParameterType) -> String {
        let value = getValue(for: parameter)
        switch parameter {
        case .confidence, .iou:
            return "\(Int(value * 100))%"
        case .maxDetections:
            return "\(Int(value))"
        case .lineThickness:
            return String(format: "%.1f", value)
        }
    }
    
    private func formatPresetLabel(_ preset: Float, for parameter: YOLOViewModel.ParameterType) -> String {
        switch parameter {
        case .confidence, .iou:
            return "\(Int(preset * 100))%"
        case .maxDetections:
            return "\(Int(preset))"
        case .lineThickness:
            return String(format: "%.1f", preset)
        }
    }
}

struct TickMarkSlider: View {
    @Binding var value: Float
    let parameter: YOLOViewModel.ParameterType
    
    var body: some View {
        VStack(spacing: 12) {
            // Slider with background
            ZStack {
                // Background for better contrast
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.2))
                    .frame(height: 60)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Track with tick marks
                        ZStack(alignment: .leading) {
                            // Main track
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.gray.opacity(0.4))
                                .frame(height: 6)
                            
                            // Active track
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.ultralyticsLime.opacity(0.8), Color.ultralyticsLime],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: fillWidth(in: geometry.size.width), height: 6)
                        }
                        
                        // Tick marks
                        HStack(spacing: 0) {
                            ForEach(0..<tickCount, id: \.self) { index in
                                if index > 0 {
                                    Spacer()
                                }
                                Rectangle()
                                    .fill(Color.white.opacity(0.6))
                                    .frame(width: 2, height: 12)
                            }
                        }
                        .frame(width: geometry.size.width)
                        
                        // Thumb
                        Circle()
                            .fill(Color.white)
                            .frame(width: 28, height: 28)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            .overlay(
                                Circle()
                                    .fill(Color.ultralyticsLime)
                                    .frame(width: 12, height: 12)
                            )
                            .offset(x: thumbOffset(in: geometry.size.width))
                            .gesture(
                                DragGesture()
                                    .onChanged { drag in
                                        updateValue(from: drag, in: geometry.size.width)
                                    }
                            )
                    }
                    .frame(height: 28)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .frame(height: 60)
            }
            
            // Tick labels
            HStack(spacing: 0) {
                ForEach(Array(tickLabels.enumerated()), id: \.offset) { index, label in
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
        }
    }
    
    private var tickCount: Int {
        switch parameter {
        case .confidence, .iou:
            return 5 // 0%, 25%, 50%, 75%, 100%
        case .maxDetections:
            return 5 // 1, 125, 250, 375, 500
        case .lineThickness:
            return 5 // 1, 3.25, 5.5, 7.75, 10
        }
    }
    
    private var tickLabels: [String] {
        switch parameter {
        case .confidence, .iou:
            return ["0", "25", "50", "75", "100"]
        case .maxDetections:
            return ["1", "125", "250", "375", "500"]
        case .lineThickness:
            return ["1", "3", "5", "8", "10"]
        }
    }
    
    private func fillWidth(in totalWidth: CGFloat) -> CGFloat {
        let normalizedValue = (value - parameter.range.lowerBound) / (parameter.range.upperBound - parameter.range.lowerBound)
        return CGFloat(normalizedValue) * totalWidth
    }
    
    private func thumbOffset(in totalWidth: CGFloat) -> CGFloat {
        fillWidth(in: totalWidth) - 14 // Center the thumb
    }
    
    private func updateValue(from drag: DragGesture.Value, in totalWidth: CGFloat) {
        let newX = min(max(0, drag.location.x), totalWidth)
        let normalizedValue = Float(newX / totalWidth)
        let rawValue = normalizedValue * (parameter.range.upperBound - parameter.range.lowerBound) + parameter.range.lowerBound
        
        // Round to step
        let steppedValue = round(rawValue / parameter.step) * parameter.step
        value = min(max(parameter.range.lowerBound, steppedValue), parameter.range.upperBound)
    }
}

// Corner radius extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}