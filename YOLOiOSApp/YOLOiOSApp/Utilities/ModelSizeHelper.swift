// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import Foundation

struct ModelSizeHelper {
    static func getModelSize(from modelName: String) -> String {
        let name = modelName.lowercased()
        
        if name.contains("11n") || name.contains("n-") || name.contains("n_") || name.hasSuffix("n") {
            return "NANO"
        } else if name.contains("11s") || name.contains("s-") || name.contains("s_") || name.hasSuffix("s") {
            return "SMALL"
        } else if name.contains("11m") || name.contains("m-") || name.contains("m_") || name.hasSuffix("m") {
            return "MEDIUM"
        } else if name.contains("11l") || name.contains("l-") || name.contains("l_") || name.hasSuffix("l") {
            return "LARGE"
        } else if name.contains("11x") || name.contains("x-") || name.contains("x_") || name.hasSuffix("x") {
            return "XLARGE"
        }
        
        // Default size based on common patterns
        return "SMALL"
    }
}