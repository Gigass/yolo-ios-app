# 外部ディスプレイ機能のデバッグガイド

## 現象：iPhone で真っ黒の画面が表示される

### 原因の可能性

1. **Scene Delegate が正しく動作していない**
   - Info.plist の設定ミス
   - Storyboard のエントリーポイント未設定

2. **ビルド設定の問題**
   - ターゲットメンバーシップの不整合
   - Scene Delegate がビルドに含まれていない

### デバッグ手順

#### 1. Xcode コンソールログを確認

ビルド実行後、以下のログを確認：
```
SceneDelegate: scene willConnectTo called
SceneDelegate: Window created with frame: ...
SceneDelegate: Root view controller set
SceneDelegate: Window made key and visible
```

これらのログが表示されない場合、Scene Delegate が呼ばれていません。

#### 2. Info.plist の確認

以下を確認：
- `UIApplicationSceneManifest` が正しく設定されている
- `UISceneConfigurationName` が "Default Configuration"
- `UISceneDelegateClassName` が $(PRODUCT_MODULE_NAME).SceneDelegate
- `UISceneStoryboardFile` が "Main"

#### 3. Storyboard の確認

1. Main.storyboard を開く
2. Initial View Controller が設定されているか確認
3. ViewController のクラスが正しく設定されているか確認

#### 4. 一時的な回避策

Scene Delegate を無効にして従来の方式に戻す：

1. Info.plist から `UIApplicationSceneManifest` セクション全体を削除
2. `UIMainStoryboardFile` を追加：
   ```xml
   <key>UIMainStoryboardFile</key>
   <string>Main</string>
   ```
3. AppDelegate に window プロパティを追加：
   ```swift
   var window: UIWindow?
   ```

### 外部ディスプレイのテスト

外部ディスプレイが接続されていない状態でも、アプリは正常に動作する必要があります。

#### シミュレーターでの確認

1. **Device メニュー** → **External Displays** → **Apple TV** を選択
2. 外部ディスプレイウィンドウが表示される
3. アプリを実行して両方の画面を確認

#### 実機での確認

1. Lightning Digital AV アダプタまたは USB-C ケーブルで接続
2. Xcode のコンソールで以下のログを確認：
   ```
   External display connected
   Available display modes:
   External display set to resolution: ...
   ```

### トラブルシューティングチェックリスト

- [ ] SceneDelegate.swift がプロジェクトに追加されている
- [ ] SceneDelegate.swift のターゲットメンバーシップが正しい
- [ ] Info.plist の UIApplicationSceneManifest が正しく設定されている
- [ ] Main.storyboard に Initial View Controller が設定されている
- [ ] Build Settings で PRODUCT_MODULE_NAME が正しく設定されている
- [ ] Clean Build Folder (Shift+Cmd+K) を実行した

### 推奨される次のステップ

1. **コンソールログを確認**して、どの段階で問題が発生しているか特定
2. **従来の方式に一時的に戻す**ことで、外部ディスプレイ機能以外は正常に動作することを確認
3. **段階的に Scene Delegate を有効化**して問題を切り分け