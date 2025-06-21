// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import Foundation

struct RemoteModelRegistry {
    static func models(for taskName: String) -> [ModelEntry] {
        guard let remoteModels = remoteModelsInfo[taskName] else { return [] }
        
        return remoteModels.map { modelInfo in
            ModelEntry(
                identifier: modelInfo.modelName,
                displayName: modelInfo.modelName,
                task: taskName,
                isRemote: true,
                isLocalBundle: false
            )
        }
    }
}