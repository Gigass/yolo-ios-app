# Alternative YOLOView Setup (If Needed)

If you continue to have issues with empty model path at startup, you can change from Storyboard initialization to programmatic initialization:

## Option 1: Keep Storyboard but delay initialization

```swift
// In ViewController
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Temporarily hide YOLOView until model is ready
    yoloView.isHidden = true
    
    // ... other setup ...
    
    // When model is loaded in loadModel():
    yoloView.isHidden = false
}
```

## Option 2: Remove from Storyboard and create programmatically

1. **Remove YOLOView from Main.storyboard**
   - Select the YOLOView in Interface Builder
   - Delete it
   - Remove the `@IBOutlet` connection

2. **Change outlet to regular property**
```swift
// Change from:
@IBOutlet weak var yoloView: YOLOView!

// To:
var yoloView: YOLOView!
```

3. **Create YOLOView programmatically**
```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    // Create YOLOView placeholder first
    let placeholderView = UIView(frame: view.bounds)
    placeholderView.backgroundColor = .black
    view.insertSubview(placeholderView, at: 0)
    
    // ... other setup ...
    
    // Create YOLOView when first model is ready
    // This happens in reloadModelEntriesAndLoadFirst
}

private func createYOLOViewIfNeeded(modelPath: String, task: YOLOTask) {
    if yoloView == nil {
        yoloView = YOLOView(frame: view.bounds, modelPathOrName: modelPath, task: task)
        view.insertSubview(yoloView, at: 0)
        
        // Setup constraints
        yoloView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            yoloView.topAnchor.constraint(equalTo: view.topAnchor),
            yoloView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            yoloView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            yoloView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        yoloView.delegate = self
        yoloView.labelName.isHidden = true
        yoloView.labelFPS.isHidden = true
    }
}
```

## Current Workaround

The current implementation should work fine because:
1. YOLOView can initialize without a model
2. Model is set immediately after viewDidLoad
3. The empty model path should not cause crashes

If you're seeing error messages but the app works correctly, you can safely ignore them. They're just initialization warnings.