# ビルドエラー修正手順

## 修正済みの内容

### 1. エラー: "Value of type 'YOLOView' has no member 'predictor'"
- **原因**: YOLOView の predictor プロパティは公開されていない
- **修正**: predictor への直接アクセスを削除し、代わりにモデル変更通知を使用

### 2. エラー: "Cannot find 'VideoFrameManager' in scope"
- **原因**: VideoFrameManager がビルドターゲットに追加されていない
- **修正**: VideoFrameManager.swift を削除し、代わりに ExternalDisplayManager.swift を作成

### 3. エラー: "Deinitializers may only be declared within a class"
- **原因**: deinit が extension 内に記述されていた
- **修正**: deinit を ViewController クラス本体に移動

## Xcode での追加手順

### 必要なファイルをプロジェクトに追加：

1. **以下のファイルを追加**（YOLOiOSApp グループを右クリック → "Add Files to YOLOiOSApp..."）：
   - SceneDelegate.swift
   - ExternalSceneDelegate.swift
   - ExternalViewController.swift
   - ExternalYOLOView.swift
   - ExternalDisplayManager.swift ← 新規作成

2. **削除されたファイル**（プロジェクトから削除）：
   - VideoFrameManager.swift
   - YOLOView+ExternalDisplay.swift

### ビルド手順：

1. **クリーンビルド**: Shift+Cmd+K
2. **ビルド**: Cmd+B
3. **実行**: Cmd+R

## 追加の修正が必要な場合

もし他のエラーが出た場合は、以下を確認：

1. **Import エラー**
   ```swift
   import YOLO  // YOLO パッケージが正しく解決されているか
   ```

2. **ターゲットメンバーシップ**
   - 各ファイルの右側の Inspector で "Target Membership" が YOLOiOSApp にチェックされているか確認

3. **Info.plist の確認**
   - Scene Manifest の設定が正しいか確認

## テスト方法

1. **シミュレーターでの基本動作確認**
   - アプリが起動することを確認
   - モデル選択が動作することを確認

2. **実機での外部ディスプレイテスト**
   - Lightning Digital AV アダプタまたは USB-C 接続
   - 外部ディスプレイ接続時のログを確認