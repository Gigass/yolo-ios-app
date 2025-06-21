# iPhone 16 USB-C ディスプレイ接続問題の解決

## 問題の状況
- iPhone 16（USB-C 搭載）
- パソコンでは動作する USB-C ケーブル使用
- Dell ディスプレイに「USB-C 信号がありません」と表示
- HDMI ポートは使用したくない

## 原因と解決方法

### 1. iPhone の USB-C 出力を有効にする

**設定を確認：**
1. iPhone の「設定」アプリを開く
2. 「画面表示と明るさ」を確認
3. 外部ディスプレイの設定があるか確認

**コントロールセンターから：**
1. コントロールセンターを開く
2. 「画面ミラーリング」をタップ
3. 外部ディスプレイが表示されるか確認

### 2. ケーブルを抜き差しする順序

正しい接続順序：
1. Dell ディスプレイの電源を入れる
2. USB-C ケーブルをディスプレイに接続
3. iPhone のロックを解除
4. USB-C ケーブルを iPhone に接続
5. 「このアクセサリを信頼しますか？」が表示されたら「信頼」をタップ

### 3. Dell ディスプレイ側の設定

**入力ソースの手動選択：**
1. Dell ディスプレイのメニューボタンを押す
2. 「入力ソース」を選択
3. 「USB-C」または「Type-C」を手動で選択
4. 自動検出ではなく、明示的に選択することが重要

**USB-C ポートの確認：**
- Dell ディスプレイに複数の USB-C ポートがある場合
- 映像入力対応ポート（通常は USB-C with DisplayPort と表記）を使用
- USB アップストリームポートでは映像表示不可

### 4. iPhone 16 特有の設定

**USB-C の動作モード：**
1. 設定 → Face ID とパスコード
2. 「USB アクセサリ」をオンにする
3. これにより、ロック中でも USB-C デバイスを認識

**省電力モードの確認：**
- 省電力モードがオンの場合、外部ディスプレイ出力が制限される可能性
- 設定 → バッテリー → 省電力モードをオフ

### 5. アプリ側の動作確認

**Xcode コンソールで確認すべきログ：**
```
SceneDelegate: scene willConnectTo called
External display connected
Available display modes:
```

これらが表示されない場合：
- アプリが外部ディスプレイを認識していない
- iOS レベルで接続が確立されていない

### 6. 代替テスト方法

**別のアプリでテスト：**
1. 写真アプリを開く
2. 動画を再生
3. 外部ディスプレイに表示されるか確認

これで表示される場合：
- ケーブルと接続は正常
- アプリ側の問題の可能性

### 7. トラブルシューティング手順

1. **iPhone を再起動**
2. **別の USB-C ポートを試す**（Dell ディスプレイ側）
3. **ケーブルの向きを逆にする**（USB-C は裏表がないが、まれに相性問題）
4. **設定 → 一般 → 転送またはリセット → リセット → 位置情報とプライバシーをリセット**

### 8. それでも動作しない場合

**Apple 公式の USB-C Digital AV Multiport アダプタを使用：**
- USB-C → HDMI 変換
- より確実な接続
- 4K 60Hz 対応

**動作確認済みの構成：**
- iPhone 15 Pro/16 + Apple USB-C ケーブル（Thunderbolt 4）+ Dell U2723DE
- iPhone 15/16 + Anker USB-C ケーブル（映像対応）+ Dell S2722DC

### 9. デバッグ用コード追加

ViewController.swift に以下を追加してテスト：

```swift
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    // 外部ディスプレイの接続状態を確認
    if UIScreen.screens.count > 1 {
        print("External display detected at app level")
        let externalScreen = UIScreen.screens[1]
        print("External screen: \(externalScreen)")
        print("Available modes: \(externalScreen.availableModes)")
    } else {
        print("No external display detected at app level")
    }
}
```