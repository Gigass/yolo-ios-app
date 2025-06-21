# Apple Display 外部出力対応手順 (Swift/UIKit)

## 1. 背景と目的
iPhone アプリを **Studio Display / Apple Display** などの外部モニタへ「ただの画面ミラーリング」ではなく、  
**ネイティブ解像度 (〜5K) いっぱいに表示** させる方法をまとめます。  
ポイントは **外部ディスプレイ専用ウインドウシーン** を作成して、`UIScreen.currentMode` で最適解像度を選択することです。

---

## 2. 実装フロー概要
| # | 作業 | 目的 |
|---|------|------|
| 1 | **Info.plist** に *External Display* 用 `UIScene` 設定を追加 | 外部接続した瞬間に iOS がシーンを起動できるようにする |
| 2 | `ExternalSceneDelegate` を実装 | 外部ディスプレイの `UIScreen` に合わせて `UIWindow` を生成 |
| 3 | `availableModes` から最高解像度を選択して `currentMode` を設定 | ドットバイドットで描画 |
| 4 | Auto Layout でレイアウトを組む | 解像度依存のハードコーディングを避ける |
| 5 | 接続／切断／解像度変更通知を監視 | 動的な画面状態の変化に追従 |

---

## 3. Info.plist 設定
```xml
<!-- UIApplicationSceneManifest に追記 -->
<key>UIApplicationSceneManifest</key>
<dict>
  <key>UISceneConfigurations</key>
  <dict>
    <!-- 外部ディスプレイ用 -->
    <key>UIWindowSceneSessionRoleExternalDisplay</key>
    <array>
      <dict>
        <key>UISceneConfigurationName</key>
        <string>External Display</string>
        <key>UISceneDelegateClassName</key>
        <string>$(PRODUCT_MODULE_NAME).ExternalSceneDelegate</string>
        <key>UISceneClassName</key>
        <string>UIWindowScene</string>
      </dict>
    </array>
  </dict>
</dict>
```

---

## 4. `ExternalSceneDelegate.swift`
```swift
import UIKit

class ExternalSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let winScene = scene as? UIWindowScene else { return }
        let extScreen = winScene.screen          // 外部ディスプレイ

        // 4‑1. 最も高解像度の UIScreenMode を適用
        if let best = extScreen.availableModes.max(by: { $0.size.width < $1.size.width }) {
            extScreen.currentMode = best
        }

        // 4‑2. UIWindow を生成
        let w = UIWindow(windowScene: winScene)
        w.frame = extScreen.bounds
        w.screen = extScreen
        w.overscanCompensation = .scale          // TV 端オチ対策
        w.rootViewController = ExternalRootVC()  // 外部表示専用 VC
        w.isHidden = false
        self.window = w
    }
}
```

---

## 5. Auto Layout と Size Class
* `extScreen.bounds` は **ポイント** 単位。  
  通常通り Auto Layout 制約を張れば 5K でもフルサイズで描画されます。
* 横幅が非常に広くなるため、多くの場合 **Regular/Regular** の Size Class になります。  
  `compact` 前提の UI は崩れるので、Size Class 切り替えを確認しましょう。

---

## 6. 画面接続・切断イベントの監視
```swift
NotificationCenter.default.addObserver(
    self,
    selector: #selector(screenDidConnect(_:)),
    name: UIScreen.didConnectNotification,
    object: nil)

NotificationCenter.default.addObserver(
    self,
    selector: #selector(screenDidDisconnect(_:)),
    name: UIScreen.didDisconnectNotification,
    object: nil)
```
* 接続時に外部ウインドウを生成、切断時に破棄。  
* `UIScreenMode.didChangeNotification` で解像度変更も監視しておくと安全です。

---

## 7. 運用 Tips
* **ミラーリングでは解像度は変えられない**  
  * ミラーリングは iOS による 16:9 スケーリング固定。
* **`currentMode` 設定は任意**  
  * 一部ディスプレイはモード固定で `availableModes` が 1 つしか返りません。
* **Trait Collection で UI 分岐**  
  * `userInterfaceIdiom == .mac` や `.pad` などを利用して、Catalyst/Mac 対応も視野に。

---

## 8. 参考リンク
* [Apple - External Display Programming Guide](https://developer.apple.com/documentation/uikit/uiscreen)  
* WWDC21 Session 10297 *“Bring Your iPad App to the External Display”*  

---

© 2025 YourCompany. Licensed under MIT.
