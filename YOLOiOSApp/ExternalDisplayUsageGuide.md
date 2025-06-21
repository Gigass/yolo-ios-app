# YOLO iOS App 外部ディスプレイ使用ガイド

## 概要
YOLO iOS アプリは外部ディスプレイ（Apple Studio Display、Dell モニター等）への出力に対応しています。メインデバイスでコントロールしながら、外部ディスプレイでクリーンな検出結果を表示できます。

## 対応ディスプレイ
- **Apple Studio Display** (5K: 5120×2880)
- **Dell 4K/QHD/FHD モニター**
- **LG UltraFine シリーズ**
- **その他 USB-C/HDMI/DisplayPort 対応ディスプレイ**

## セットアップ手順

### 1. Xcode でのプロジェクト設定

新しいファイルをプロジェクトに追加：
1. Xcode で `YOLOiOSApp.xcodeproj` を開く
2. プロジェクトナビゲーターで `YOLOiOSApp` グループを右クリック
3. "Add Files to YOLOiOSApp..." を選択
4. 以下のファイルを選択して追加：
   - `SceneDelegate.swift`
   - `ExternalSceneDelegate.swift`
   - `ExternalViewController.swift`
   - `ExternalYOLOView.swift`
   - `VideoFrameManager.swift`
   - `YOLOView+ExternalDisplay.swift`

### 2. ディスプレイの接続

#### Lightning 端子の iPhone（iPhone 14 以前）

##### HDMI 接続（最も一般的）
1. **Apple Lightning - Digital AV アダプタ**（純正推奨）を iPhone に接続
2. HDMI ケーブルをアダプタとディスプレイに接続
3. ディスプレイの入力ソースを HDMI に設定
4. 最大解像度：1080p（1920×1080）@ 60Hz

##### VGA 接続（古いディスプレイ用）
1. **Apple Lightning - VGA アダプタ**を使用
2. VGA ケーブルで接続
3. 最大解像度：1080p（1920×1080）

⚠️ **注意**: Lightning to USB-C ケーブルでは映像出力できません。必ず上記の専用アダプタが必要です。

#### USB-C 端子の iPhone（iPhone 15 以降）

##### USB-C 接続（推奨）
1. USB-C ケーブルでディスプレイと iPhone を直接接続
2. ディスプレイの電源を入れ、入力ソースを USB-C に設定
3. 最大解像度：4K（3840×2160）以上対応

##### HDMI 接続
1. USB-C - HDMI アダプタを使用
2. HDMI ケーブルでディスプレイと接続
3. 最大解像度：4K（3840×2160）@ 60Hz

## 使用方法

### 基本的な使い方

1. **アプリを起動**
   - 通常通り YOLO iOS アプリを起動

2. **外部ディスプレイを接続**
   - ディスプレイを接続すると自動的に検出
   - 最高解像度が自動選択される

3. **モデルの選択**
   - メインデバイスでタスク（Detect/Segment/Classify/Pose/OBB）を選択
   - モデルを選択すると外部ディスプレイにも反映

4. **検出の実行**
   - カメラ映像と検出結果が外部ディスプレイにリアルタイム表示
   - メインデバイスには操作用コントロールが表示

### 画面構成

#### メインデバイス（iPhone/iPad）
- モデル選択 UI
- パラメータ調整スライダー（Confidence、IoU、Max Results）
- FPS/推論時間の表示
- 録画/共有ボタン

#### 外部ディスプレイ
- フルスクリーンのカメラ映像
- 検出結果のオーバーレイ表示
- UI コントロールなしのクリーンな表示

## 高度な機能

### 解像度の確認
Xcode のコンソールで利用可能な解像度を確認：
```
Available display modes:
  - 1920.0 x 1080.0
  - 2560.0 x 1440.0
  - 3840.0 x 2160.0
External display set to resolution: (3840.0, 2160.0)
```

### 特定解像度の強制
`ExternalSceneDelegate.swift` を編集して特定の解像度を設定可能：
```swift
// 例：1920x1080 に固定
if let hdMode = externalScreen.availableModes.first(where: { 
    $0.size.width == 1920 && $0.size.height == 1080 
}) {
    externalScreen.currentMode = hdMode
}
```

## タスク別の表示

### Object Detection (Detect)
- バウンディングボックスとラベル表示
- 信頼度スコア付き

### Segmentation (Segment)
- セグメンテーションマスクのオーバーレイ
- 半透明で元画像と重ね合わせ

### Classification (Classify)
- 画面中央に分類結果を表示
- トップクラスのラベル

### Pose Estimation (Pose)
- キーポイントと骨格の表示
- 人物の姿勢を可視化

### Oriented Bounding Box (OBB)
- 回転したバウンディングボックス
- 物体の向きを正確に表示

## トラブルシューティング

### ディスプレイが認識されない
1. ケーブルの接続を確認
2. ディスプレイの電源と入力ソース設定を確認
3. アダプターを使用している場合は直接接続を試す

### 解像度が低い
1. Xcode コンソールで利用可能な解像度を確認
2. ケーブルが高解像度に対応しているか確認（USB 3.0 以上推奨）

### パフォーマンスの問題
1. 高解像度（4K 以上）では若干の遅延が発生する可能性
2. メインデバイスで Max Results を調整して負荷を軽減

## 注意事項

- 外部ディスプレイ機能は iOS 13.0 以上で利用可能
- 実機でのみ動作（シミュレーターでは利用不可）
- バッテリー消費が増加するため、電源接続推奨
- 一部の古いディスプレイでは最高解像度が選択できない場合あり

### Lightning 端子 iPhone の制限事項
- **最大解像度は 1080p（1920×1080）に制限**
- 4K/5K ディスプレイに接続しても 1080p で出力
- Lightning - Digital AV アダプタは充電用 Lightning ポート付きなので、充電しながら使用可能
- 非純正アダプタは動作が不安定な場合があるため、Apple 純正品を推奨

### 必要なアダプタ（Lightning iPhone 用）
- **Apple Lightning - Digital AV アダプタ**（型番：MD826AM/A）
  - HDMI 出力 + 充電用 Lightning ポート
  - 価格：約 7,500 円
- **Apple Lightning - VGA アダプタ**（型番：MD825AM/A）
  - VGA 出力のみ
  - 価格：約 6,500 円

## フィードバック

問題や改善提案がある場合は、GitHub Issues でご報告ください：
https://github.com/ultralytics/yolo-ios-app/issues