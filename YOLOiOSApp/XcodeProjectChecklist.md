# Xcode プロジェクト設定チェックリスト

## 手順 1: ファイルの追加確認

Xcode でプロジェクトナビゲーター（左側のファイルリスト）を確認し、以下のファイルがリストに表示されているか確認：

- [ ] SceneDelegate.swift
- [ ] ExternalSceneDelegate.swift
- [ ] ExternalViewController.swift
- [ ] ExternalYOLOView.swift
- [ ] ExternalDisplayManager.swift

**ファイルが表示されていない場合：**

1. プロジェクトナビゲーターで `YOLOiOSApp` グループを右クリック
2. "Add Files to YOLOiOSApp..." を選択
3. 不足しているファイルを選択して追加

## 手順 2: ターゲットメンバーシップの確認

各ファイルについて：

1. ファイルを選択
2. 右側の File Inspector を開く（⌥⌘1）
3. "Target Membership" セクションで `YOLOiOSApp` にチェックが入っているか確認

特に重要なファイル：
- **SceneDelegate.swift** - 必須
- **ExternalSceneDelegate.swift** - 必須

## 手順 3: ビルド設定の確認

1. プロジェクトを選択 → TARGETS → YOLOiOSApp
2. Build Settings タブ
3. 検索バーに "PRODUCT_MODULE_NAME" と入力
4. 値が "YOLOiOSApp" になっているか確認

## 手順 4: Info.plist の確認

Info.plist で以下を確認：

```xml
<key>UISceneDelegateClassName</key>
<string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
```

これが以下のように展開されることを確認：
- `YOLOiOSApp.SceneDelegate`

## 手順 5: クリーンビルド

1. Product → Clean Build Folder (Shift+Cmd+K)
2. Product → Build (Cmd+B)

## 手順 6: ファイルの場所確認

ターミナルで実際のファイルが存在するか確認：

```bash
ls -la /Users/majimadaisuke/Downloads/release/yolo-ios-app/YOLOiOSApp/YOLOiOSApp/*.swift | grep -E "(Scene|External)"
```

期待される出力：
```
ExternalDisplayManager.swift
ExternalSceneDelegate.swift
ExternalViewController.swift
ExternalYOLOView.swift
SceneDelegate.swift
```

## トラブルシューティング

### エラー: "could not load class with name"

1. `@objc(ClassName)` アノテーションを追加（完了済み）
2. ファイルがビルドフェーズに含まれているか確認：
   - TARGETS → YOLOiOSApp → Build Phases → Compile Sources
   - SceneDelegate.swift が含まれているか確認

### それでも動作しない場合

一時的に Scene Delegate を無効にする：

1. Info.plist から `UIApplicationSceneManifest` 全体を削除
2. AppDelegate.swift に追加：
   ```swift
   var window: UIWindow?
   ```
3. Info.plist に追加：
   ```xml
   <key>UIMainStoryboardFile</key>
   <string>Main</string>
   ```

これで従来の方式に戻り、アプリは正常に動作するはずです（外部ディスプレイ機能なし）。