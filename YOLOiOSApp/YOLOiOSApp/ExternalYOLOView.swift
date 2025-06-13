// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import UIKit
import YOLO
import CoreMedia
import AVFoundation

/// A simplified YOLO view for external display that mirrors the main display
class ExternalYOLOView: UIView {
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var boundingBoxViews: [BoundingBoxView] = []
    private var overlayLayer = CALayer()
    private var maskLayer = CALayer()
    private var poseLayer = CALayer()
    private var obbLayer = CALayer()
    
    private var currentTask: YOLOTask = .detect
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    private func setupLayers() {
        backgroundColor = .black
        
        // Add a test view to ensure rendering works
        let testLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 30))
        testLabel.text = "External YOLO View Active"
        testLabel.textColor = .green
        testLabel.font = .systemFont(ofSize: 20)
        addSubview(testLabel)
        
        // Setup overlay layers
        layer.addSublayer(overlayLayer)
        layer.addSublayer(maskLayer)
        layer.addSublayer(poseLayer)
        layer.addSublayer(obbLayer)
        
        // Configure layers
        overlayLayer.frame = bounds
        maskLayer.frame = bounds
        poseLayer.frame = bounds
        obbLayer.frame = bounds
        
        overlayLayer.zPosition = 100
        maskLayer.zPosition = 90
        poseLayer.zPosition = 110
        obbLayer.zPosition = 110
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update all layer frames
        previewLayer?.frame = bounds
        overlayLayer.frame = bounds
        maskLayer.frame = bounds
        poseLayer.frame = bounds
        obbLayer.frame = bounds
        
        // Update bounding box positions
        boundingBoxViews.forEach { $0.frame = bounds }
    }
    
    /// Display video preview layer
    func setupPreviewLayer(_ session: AVCaptureSession) {
        previewLayer?.removeFromSuperlayer()
        
        let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        newPreviewLayer.videoGravity = .resizeAspect
        newPreviewLayer.frame = bounds
        layer.insertSublayer(newPreviewLayer, at: 0)
        
        previewLayer = newPreviewLayer
    }
    
    /// Update task type
    func setTask(_ task: YOLOTask) {
        currentTask = task
        clearAllResults()
    }
    
    /// Display YOLO results
    func displayResults(_ results: YOLOResult) {
        print("🟡 ExternalYOLOView displayResults called with task: \(currentTask)")
        
        clearAllResults()
        
        // If we have an annotated image, display it directly
        if let annotatedImage = results.annotatedImage {
            print("🟢 Displaying annotated image")
            let imageLayer = CALayer()
            imageLayer.contents = annotatedImage.cgImage
            imageLayer.frame = bounds
            imageLayer.contentsGravity = .resizeAspect
            layer.insertSublayer(imageLayer, at: 0)
        } else {
            print("⚠️ No annotated image available, showing boxes")
            // Fallback to drawing boxes
            switch currentTask {
            case .detect, .obb:
                showBoxes(predictions: results)
            case .segment:
                showSegmentationMask(results: results)
            case .classify:
                showClassification(results: results)
            case .pose:
                showPose(results: results)
            }
        }
    }
    
    private func clearAllResults() {
        // Clear bounding boxes
        boundingBoxViews.forEach { $0.hide() }
        
        // Clear layers
        maskLayer.contents = nil
        poseLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        obbLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
    }
    
    private func showBoxes(predictions: YOLOResult) {
        let ratio = bounds.width / predictions.orig_shape.width
        
        for (index, box) in predictions.boxes.enumerated() {
            guard index < 100 else { break } // Limit boxes
            
            // Create or reuse bounding box view
            let boxView: BoundingBoxView
            if index < boundingBoxViews.count {
                boxView = boundingBoxViews[index]
            } else {
                boxView = BoundingBoxView()
                boundingBoxViews.append(boxView)
                addSubview(boxView)
            }
            
            // Use the xywh rect directly - it's already in image coordinates
            let rect = box.xywh
            let scaledRect = CGRect(
                x: rect.origin.x * ratio,
                y: rect.origin.y * ratio,
                width: rect.width * ratio,
                height: rect.height * ratio
            )
            
            let label = box.cls
            let confidence = String(format: "%.2f", box.conf)
            
            boxView.show(
                frame: scaledRect,
                label: label,
                confidence: confidence,
                color: UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
            )
        }
    }
    
    private func showSegmentationMask(results: YOLOResult) {
        // Simplified segmentation display
        if let maskImage = results.annotatedImage {
            maskLayer.contents = maskImage.cgImage
            maskLayer.opacity = 0.5
        }
    }
    
    private func showClassification(results: YOLOResult) {
        // Show top classification result
        if let topClass = results.boxes.first {
            let textLayer = CATextLayer()
            textLayer.string = topClass.cls
            textLayer.fontSize = 24
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.alignmentMode = .center
            textLayer.frame = CGRect(x: 0, y: bounds.height/2 - 20, width: bounds.width, height: 40)
            
            overlayLayer.addSublayer(textLayer)
        }
    }
    
    private func showPose(results: YOLOResult) {
        // Simplified pose display - would need full implementation
        // For now, just show bounding boxes
        showBoxes(predictions: results)
    }
}

// Simple bounding box view for external display
private class BoundingBoxView: UIView {
    private let labelLayer = CATextLayer()
    private let borderLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(borderLayer)
        layer.addSublayer(labelLayer)
        
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2
        
        labelLayer.fontSize = 14
        labelLayer.foregroundColor = UIColor.white.cgColor
        labelLayer.backgroundColor = UIColor.black.withAlphaComponent(0.5).cgColor
        labelLayer.alignmentMode = .left
        labelLayer.contentsScale = UIScreen.main.scale
    }
    
    func show(frame: CGRect, label: String, confidence: String, color: UIColor) {
        self.frame = frame
        isHidden = false
        
        // Update border
        let path = UIBezierPath(rect: bounds)
        borderLayer.path = path.cgPath
        borderLayer.strokeColor = color.cgColor
        
        // Update label
        let text = "\(label) \(confidence)"
        labelLayer.string = text
        labelLayer.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 20)
    }
    
    func hide() {
        isHidden = true
    }
}