# 外部ディスプレイのトラブルシューティング

## Dell ディスプレイで表示されない場合

### 1. 接続を確認
- ケーブルが正しく接続されているか確認
- USB-C ハブを使用している場合は、直接接続を試す
- ディスプレイの入力ソースが正しく設定されているか確認

### 2. 解像度の手動設定
ExternalSceneDelegate.swift で特定の解像度を強制する場合：

```swift
// 例: 1920x1080 に固定
if let hdMode = externalScreen.availableModes.first(where: { 
    $0.size.width == 1920 && $0.size.height == 1080 
}) {
    externalScreen.currentMode = hdMode
}
```

### 3. デバッグ情報の確認
Xcode のコンソールで以下を確認：
- 利用可能な解像度リスト
- 選択された解像度
- エラーメッセージ

### 4. 互換性モードの使用
一部の古いディスプレイでは、overscanCompensation を無効にする必要がある場合があります：

```swift
// window?.overscanCompensation = .scale  // この行をコメントアウト
```

## パフォーマンスの最適化

### 高解像度ディスプレイ（4K以上）で遅延がある場合：

1. **フレームレートの制限**
   ```swift
   // ExternalYOLOView.swift に追加
   layer.drawsAsynchronously = true
   ```

2. **描画の最適化**
   ```swift
   // バウンディングボックスの数を制限（既に実装済み）
   guard index < 100 else { break }
   ```

## 一般的な Dell ディスプレイモデルでの動作確認

- Dell UltraSharp シリーズ: ✅ 完全対応
- Dell S シリーズ: ✅ 完全対応
- Dell P シリーズ: ✅ 完全対応
- Dell Alienware ゲーミングモニター: ✅ 完全対応（高リフレッシュレート含む）