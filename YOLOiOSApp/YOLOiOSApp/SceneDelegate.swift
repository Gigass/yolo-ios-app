// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import UIKit

@objc(SceneDelegate)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        print("SceneDelegate: scene willConnectTo called")
        
        guard let windowScene = scene as? UIWindowScene else { 
            print("SceneDelegate: Failed to cast scene to UIWindowScene")
            return 
        }
        
        // Create window for the main app scene
        window = UIWindow(windowScene: windowScene)
        print("SceneDelegate: Window created with frame: \(window?.frame ?? .zero)")
        
        // Load the main storyboard and instantiate the initial view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootViewController = storyboard.instantiateInitialViewController() {
            window?.rootViewController = rootViewController
            print("SceneDelegate: Root view controller set")
        } else {
            print("SceneDelegate: Failed to instantiate initial view controller from Main.storyboard")
        }
        
        window?.makeKeyAndVisible()
        print("SceneDelegate: Window made key and visible")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
    }
}