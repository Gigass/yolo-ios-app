// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI
import YOLO

struct TaskTabsView: View {
    @Binding var selectedTask: YOLOTask
    @State private var underlineOffset: CGFloat = 0
    @State private var underlineWidth: CGFloat = 0
    
    let tasks: [YOLOTask] = [.detect, .segment, .classify, .pose, .obb]
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(tasks, id: \.self) { task in
                            TaskTab(
                                task: task,
                                isSelected: selectedTask == task,
                                action: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedTask = task
                                    }
                                }
                            )
                            .id(task)
                            .background(
                                GeometryReader { tabGeometry in
                                    Color.clear
                                        .preference(
                                            key: TabPreferenceKey.self,
                                            value: selectedTask == task ? [
                                                TabPreference(
                                                    task: task,
                                                    frame: tabGeometry.frame(in: .named("scroll"))
                                                )
                                            ] : []
                                        )
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(TabPreferenceKey.self) { preferences in
                        if let preference = preferences.first {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                underlineOffset = preference.frame.minX
                                underlineWidth = preference.frame.width
                            }
                        }
                    }
                }
                .overlay(alignment: .bottom) {
                    // Animated underline
                    Rectangle()
                        .fill(Color.ultralyticsLime)
                        .frame(width: underlineWidth, height: 2)
                        .offset(x: underlineOffset - geometry.size.width / 2 + underlineWidth / 2)
                }
                .onChange(of: selectedTask) { newTask in
                    withAnimation {
                        proxy.scrollTo(newTask, anchor: .center)
                    }
                }
            }
        }
        .frame(height: 28)
        .background(Color.ultralyticsSurfaceDark)
    }
}

struct TaskTab: View {
    let task: YOLOTask
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(task.displayName.uppercased())
                .font(.tabLabel)
                .foregroundColor(isSelected ? .ultralyticsLime : .ultralyticsTextSubtle)
                .padding(.horizontal, 16)
                .frame(height: 28)
        }
    }
}

// Preference key for tab positioning
struct TabPreference: Equatable {
    let task: YOLOTask
    let frame: CGRect
}

struct TabPreferenceKey: PreferenceKey {
    static var defaultValue: [TabPreference] = []
    
    static func reduce(value: inout [TabPreference], nextValue: () -> [TabPreference]) {
        value.append(contentsOf: nextValue())
    }
}

// Typography extension
extension Font {
    static let tabLabel = Font.system(size: 13, weight: .medium)
}