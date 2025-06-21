# YOLOiOSApp モデルドロップダウン実装計画

## 概要
現在のポップアップ式モデル選択を、hub-appのようなドロップダウン式に変更する実装計画。

## 現状分析

### 現在の実装
- **UIAlertController**のactionSheetスタイルを使用
- 画面下部からポップアップ
- シンプルなリスト表示

### hub-appの実装
- 上部バーから展開するドロップダウン
- 半透明オーバーレイ
- セクション分け（Selected、Custom Models、その他）
- ダウンロード状態の表示
- アニメーション付き

## 実装計画

### Phase 1: 基本的なドロップダウンUI

#### 1.1 新しいコンポーネント作成
```swift
// ModelDropdownView.swift
class ModelDropdownView: UIView {
    // ドロップダウンの実装
}
```

#### 1.2 主要機能
- StatusMetricBarの下に表示
- 半透明オーバーレイ（背景タップで閉じる）
- アニメーション（200ms、easeOutCubic相当）
- 最大高さ：画面の60%

### Phase 2: モデルリストの改善

#### 2.1 セクション構造
1. **SELECTED** - 現在選択中のモデル
2. **DOWNLOADED** - ダウンロード済みモデル
3. **AVAILABLE** - 利用可能なモデル

#### 2.2 モデル行のデザイン
```swift
// ModelDropdownRow.swift
class ModelDropdownRow: UIView {
    // 各モデル行の実装
}
```

- ステータスアイコン（選択済み、ダウンロード済み、未ダウンロード）
- モデル名とサイズ表示
- 選択時のハイライト（ライムグリーン）

### Phase 3: 状態管理

#### 3.1 モデルステータス
```swift
enum ModelStatus {
    case selected
    case downloaded
    case notDownloaded
    case downloading(progress: Float)
}
```

#### 3.2 ダウンロード進捗表示
- 円形プログレスインジケーター
- パーセンテージ表示

## UIデザイン仕様

### カラー
- **背景**: `UIColor.black.withAlphaComponent(0.98)`
- **オーバーレイ**: `UIColor.black.withAlphaComponent(0.5)`
- **選択ハイライト**: `UIColor.ultralyticsLime.withAlphaComponent(0.1)`
- **ボーダー**: `UIColor.systemGray.withAlphaComponent(0.2)`

### レイアウト
```
┌─────────────────────────────┐
│ StatusMetricBar             │
├─────────────────────────────┤
│ ▼ ModelDropdown (展開時)    │
│ ┌─────────────────────────┐ │
│ │ SELECTED                │ │
│ │ ✓ YOLO11n              │ │
│ ├─────────────────────────┤ │
│ │ DOWNLOADED             │ │
│ │ ○ YOLO11s              │ │
│ │ ○ YOLO11m              │ │
│ ├─────────────────────────┤ │
│ │ AVAILABLE              │ │
│ │ ↓ YOLO11l              │ │
│ │ ↓ YOLO11x              │ │
│ └─────────────────────────┘ │
└─────────────────────────────┘
```

## 実装ステップ

### Step 1: ModelDropdownViewの作成
1. 基本的なビュー構造
2. アニメーション実装
3. オーバーレイ処理

### Step 2: ModelDropdownRowの作成
1. 行レイアウト
2. ステータスアイコン
3. 選択ハイライト

### Step 3: ViewControllerの統合
1. showModelSelector()メソッドの置き換え
2. ドロップダウンの表示/非表示制御
3. モデル選択処理

### Step 4: 状態管理の改善
1. モデルのダウンロード状態追跡
2. 進捗表示の実装
3. セクション分けロジック

## 技術的考慮事項

### アニメーション
```swift
UIView.animate(withDuration: 0.2, 
               delay: 0,
               options: .curveEaseOut,
               animations: {
    // ドロップダウンの展開
})
```

### ジェスチャー処理
- 背景タップで閉じる
- スクロール可能（コンテンツが多い場合）
- スワイプダウンで閉じる（オプション）

### パフォーマンス
- モデルリストのキャッシング
- 効率的な再描画
- メモリ管理

## 移行戦略

1. **既存機能の維持**
   - 現在のUIAlertControllerベースの実装を残す
   - フラグで新旧切り替え可能に

2. **段階的実装**
   - Phase 1: 基本UI
   - Phase 2: 機能拡張
   - Phase 3: 完全移行

3. **テスト**
   - 各種画面サイズでの動作確認
   - ダウンロード中の状態遷移
   - メモリリークチェック

## 期待される効果

1. **UXの向上**
   - より直感的なモデル選択
   - 状態の可視化
   - スムーズなアニメーション

2. **機能性の向上**
   - モデルの整理（セクション分け）
   - ダウンロード進捗の表示
   - 将来的な機能拡張の基盤

3. **デザインの統一性**
   - hub-appとの一貫性
   - 新UIデザインとの調和