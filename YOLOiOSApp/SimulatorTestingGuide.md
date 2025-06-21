# シミュレーターでの外部ディスプレイ機能テストガイド

## 制限事項

iOS シミュレーターでは以下の制限があります：
- ❌ 実際の外部ディスプレイ接続は不可
- ❌ カメラ機能は使用不可
- ✅ UI レイアウトとコード動作は確認可能

## テスト可能な項目

### 1. Scene Delegate の動作確認

```swift
// AppDelegate.swift にデバッグコードを追加
func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    print("🔍 Scene configuration requested for role: \(connectingSceneSession.role.rawValue)")
    
    if connectingSceneSession.role == .windowApplication {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    } else if connectingSceneSession.role == .windowExternalDisplay {
        // シミュレーターでは呼ばれないが、コードパスは確認可能
        print("⚠️ External display configuration requested (not supported in simulator)")
        return UISceneConfiguration(name: "External Display Configuration", sessionRole: connectingSceneSession.role)
    }
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
}
```

### 2. モックを使用した外部ディスプレイのシミュレーション

`ViewController.swift` に追加：

```swift
#if targetEnvironment(simulator)
// シミュレーター用のテストボタンを追加
private func addSimulatorTestButton() {
    let testButton = UIButton(type: .system)
    testButton.setTitle("Simulate External Display", for: .normal)
    testButton.backgroundColor = .systemBlue
    testButton.setTitleColor(.white, for: .normal)
    testButton.layer.cornerRadius = 8
    testButton.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(testButton)
    
    NSLayoutConstraint.activate([
        testButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        testButton.widthAnchor.constraint(equalToConstant: 200),
        testButton.heightAnchor.constraint(equalToConstant: 44)
    ])
    
    testButton.addTarget(self, action: #selector(simulateExternalDisplay), for: .touchUpInside)
}

@objc private func simulateExternalDisplay() {
    print("🖥️ Simulating external display connection...")
    
    // 外部ディスプレイ接続をシミュレート
    NotificationCenter.default.post(
        name: .externalDisplayConnected,
        object: nil,
        userInfo: ["screen": UIScreen.main] // メインスクリーンで代用
    )
    
    // モックの YOLO 結果を送信
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.sendMockYOLOResults()
    }
}

private func sendMockYOLOResults() {
    // モックの検出結果を作成
    let mockResult = YOLOResult(
        orig_shape: CGSize(width: 640, height: 480),
        boxes: [
            YOLOBoundingBox(x: 320, y: 240, w: 100, h: 150, cnf: 0.95, clsId: 0)
        ],
        speed: 25.5,
        names: [0: "person"]
    )
    
    NotificationCenter.default.post(
        name: .yoloResultsAvailable,
        object: nil,
        userInfo: ["results": mockResult]
    )
    
    print("📊 Mock YOLO results sent")
}
#endif
```

### 3. UI レイアウトの確認

`ExternalViewController.swift` を単独でテスト：

```swift
#if targetEnvironment(simulator)
extension ExternalViewController {
    // シミュレーター用のプレビュー機能
    static func instantiateForTesting() -> ExternalViewController {
        let vc = ExternalViewController()
        vc.view.frame = CGRect(x: 0, y: 0, width: 1920, height: 1080) // HD
        return vc
    }
    
    func addTestOverlay() {
        let label = UILabel()
        label.text = "External Display Preview (Simulator)"
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
#endif
```

### 4. 別ウィンドウでの表示テスト

`SceneDelegate.swift` に追加：

```swift
#if targetEnvironment(simulator)
private var externalWindow: UIWindow?

func showExternalDisplayPreview() {
    // 新しいウィンドウを作成して外部ディスプレイをシミュレート
    externalWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 1920, height: 1080))
    externalWindow?.backgroundColor = .black
    
    let externalVC = ExternalViewController()
    externalWindow?.rootViewController = externalVC
    externalWindow?.windowLevel = .normal
    externalWindow?.makeKeyAndVisible()
    
    // ウィンドウを画面の右側に配置（デバッグ用）
    if let screen = window?.screen {
        externalWindow?.frame.origin.x = screen.bounds.width
    }
    
    print("🖼️ External display preview window created")
}
#endif
```

## Xcode での確認方法

### 1. デバイスシミュレーターの選択
- iPhone 15 Pro などの USB-C 対応機種を選択
- iPad Pro (USB-C) でもテスト可能

### 2. コンソールログの確認
```
🔍 Scene configuration requested for role: UIWindowSceneSessionRoleApplication
🖥️ Simulating external display connection...
📊 Mock YOLO results sent
```

### 3. ビルド設定
```swift
// Build Settings で以下を確認
OTHER_SWIFT_FLAGS = -D DEBUG
```

## 実機テストの代替案

### 1. Mac Catalyst
Mac アプリとしてビルドすれば、複数ウィンドウのテストが可能：
- Xcode で Mac (Designed for iPad) を選択
- 実際に複数ウィンドウを開いてテスト

### 2. TestFlight
- 実機を持つテスターに配布
- リモートでフィードバックを収集

### 3. Apple Store でのデモ
- 最寄りの Apple Store で実機とディスプレイを使用してテスト

## デバッグ用コードの削除

リリース前に必ずシミュレーター用コードを削除：
```bash
# シミュレーター用コードを検索
grep -r "targetEnvironment(simulator)" .
```

## まとめ

シミュレーターでは：
- ✅ コードロジックの確認
- ✅ UI レイアウトの検証
- ✅ 通知システムの動作確認
- ❌ 実際の外部ディスプレイ接続
- ❌ カメラ機能
- ❌ 解像度切り替え

完全なテストには実機が必要ですが、上記の方法で基本的な動作確認は可能です。