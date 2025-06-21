# Dell ディスプレイ接続トラブルシューティング

## 「USB-C 信号がありません」エラーの解決方法

### 1. iPhone のモデルを確認

#### iPhone 15 以降（USB-C 搭載）の場合：

**接続要件：**
- USB-C to USB-C ケーブル（DisplayPort Alt Mode 対応）
- Dell ディスプレイの USB-C ポートが映像入力対応であること

**確認事項：**
1. **ケーブルの仕様**
   - 映像転送対応の USB-C ケーブルか確認（充電専用ケーブルでは不可）
   - USB 3.1 以上、DisplayPort Alt Mode 対応が必要

2. **Dell ディスプレイの入力設定**
   - ディスプレイのメニューで入力ソースを確認
   - 「USB-C」または「Type-C」を選択
   - 複数の USB-C ポートがある場合は、映像入力対応ポートを使用

3. **代替接続方法**
   - USB-C to HDMI アダプター + HDMI ケーブル
   - USB-C to DisplayPort アダプター + DisplayPort ケーブル

#### iPhone 14 以前（Lightning 搭載）の場合：

**必須アダプター：**
- Apple Lightning - Digital AV アダプタ（HDMI 出力）
- Lightning to USB-C ケーブルでは映像出力不可

**接続方法：**
```
iPhone → Lightning Digital AV アダプタ → HDMI ケーブル → Dell ディスプレイ（HDMI 入力）
```

### 2. Dell ディスプレイの設定確認

1. **入力ソースの切り替え**
   - ディスプレイのボタンでメニューを開く
   - 「入力ソース」または「Input Source」を選択
   - 接続方法に応じて選択：
     - HDMI 1/2
     - DisplayPort
     - USB-C（一部モデルのみ）

2. **USB-C ポートの種類**
   - **映像入力対応 USB-C**: 映像信号を受信可能
   - **USB ハブ用 USB-C**: データ転送のみ（映像不可）
   - マニュアルで確認が必要

### 3. 接続診断チェックリスト

- [ ] iPhone のモデルは？（USB-C or Lightning）
- [ ] 使用しているケーブル/アダプターは映像対応？
- [ ] Dell ディスプレイの正しい入力ポートに接続？
- [ ] ディスプレイの入力ソースは正しく設定？
- [ ] ケーブルは両端とも正しく接続？

### 4. 推奨される接続構成

#### iPhone 15（USB-C）→ Dell ディスプレイ

**オプション 1: 直接接続**
- USB-C to USB-C ケーブル（映像対応）
- Dell の USB-C 入力ポートへ

**オプション 2: HDMI 経由**
- USB-C to HDMI アダプター
- HDMI ケーブル
- Dell の HDMI 入力へ

#### iPhone 14 以前（Lightning）→ Dell ディスプレイ

**唯一の方法：**
- Lightning Digital AV アダプタ
- HDMI ケーブル
- Dell の HDMI 入力へ

### 5. アプリ側の確認

Xcode のコンソールで以下のログを確認：
```
External display connected
Available display modes:
  - 1920.0 x 1080.0
  - 2560.0 x 1440.0
External display set to resolution: ...
```

これらのログが表示されない場合は、物理的な接続に問題があります。

### 6. よくある問題と解決策

| 問題 | 解決策 |
|------|--------|
| USB-C ケーブルが充電専用 | DisplayPort Alt Mode 対応ケーブルに交換 |
| Dell の USB-C がデータ専用 | HDMI または DisplayPort 入力を使用 |
| Lightning to USB-C で接続 | Lightning Digital AV アダプタに変更 |
| 入力ソースが自動検出されない | 手動で入力ソースを切り替え |

### 7. 動作確認済みの構成

- iPhone 15 Pro + USB-C ケーブル（Thunderbolt 3）+ Dell U2720Q
- iPhone 14 + Lightning Digital AV + HDMI + Dell S2722DC
- iPhone 13 + Lightning Digital AV + HDMI + Dell P2419H