// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import Foundation

extension ModelEntry {
    // Convenience initializer with task
    init(identifier: String, displayName: String, task: String, isRemote: Bool, isLocalBundle: Bool) {
        self.init(
            displayName: displayName,
            identifier: identifier,
            isLocalBundle: isLocalBundle,
            isRemote: isRemote,
            remoteURL: nil
        )
    }
    
    // Computed property to get task from identifier
    var task: String {
        if identifier.contains("-seg") || identifier.contains("_seg") {
            return "Segment"
        } else if identifier.contains("-cls") || identifier.contains("_cls") {
            return "Classify"
        } else if identifier.contains("-pose") || identifier.contains("_pose") {
            return "Pose"
        } else if identifier.contains("-obb") || identifier.contains("_obb") {
            return "OBB"
        } else {
            return "Detect"
        }
    }
}