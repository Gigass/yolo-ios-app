// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

//  BoundingBoxView for Ultralytics YOLO App
//  This class is designed to visualize bounding boxes and labels for detected objects in the YOLOv8 models within the Ultralytics YOLO app.
//  It leverages Core Animation layers to draw the bounding boxes and text labels dynamically on the detection video feed.
//  Licensed under AGPL-3.0. For commercial use, refer to Ultralytics licensing: https://ultralytics.com/license
//  Access the source code: https://github.com/ultralytics/yolo-ios-app
//
//  BoundingBoxView facilitates the clear representation of detection results, improving user interaction with the app by
//  providing immediate visual feedback on detected objects, including their classification and confidence level.

import Foundation
import UIKit

/// Manages the visualization of bounding boxes and associated labels for object detection results.
@MainActor
class BoundingBoxView {
  /// The layer that draws the bounding box around a detected object.
  let shapeLayer: CAShapeLayer

  /// The layer that displays the label and confidence score for the detected object.
  let textLayer: CATextLayer
  
  /// Reference to the parent view for dynamic sizing
  private weak var parentView: UIView?

  /// Initializes a new BoundingBoxView with configured shape and text layers.
  init() {
    shapeLayer = CAShapeLayer()
    shapeLayer.fillColor = UIColor.clear.cgColor  // No fill to only show the bounding outline
    shapeLayer.lineWidth = 4  // Default line width, will be scaled
    shapeLayer.isHidden = true  // Initially hidden; shown when a detection occurs

    textLayer = CATextLayer()
    textLayer.isHidden = true  // Initially hidden; shown with label when a detection occurs
    textLayer.contentsScale = UIScreen.main.scale  // Ensure the text is sharp on retina displays
    textLayer.fontSize = 14  // Default font size, will be scaled
    textLayer.font = UIFont(name: "Avenir", size: textLayer.fontSize)  // Use Avenir font for labels
    textLayer.alignmentMode = .center  // Center-align the text within the layer
  }
  
  /// Sets the parent view for dynamic scaling calculations
  func setParentView(_ view: UIView) {
    parentView = view
  }

  /// Adds the bounding box and text layers to a specified parent layer.
  /// - Parameter parent: The CALayer to which the bounding box and text layers will be added.
  func addToLayer(_ parent: CALayer) {
    parent.addSublayer(shapeLayer)
    parent.addSublayer(textLayer)
  }

  /// Updates the bounding box and label to be visible with specified properties.
  /// - Parameters:
  ///   - frame: The CGRect frame defining the bounding box's size and position.
  ///   - label: The text label to display (e.g., object class and confidence).
  ///   - color: The color of the bounding box stroke and label background.
  ///   - alpha: The opacity level for the bounding box stroke and label background.
  func show(frame: CGRect, label: String, color: UIColor, alpha: CGFloat) {
    CATransaction.setDisableActions(true)  // Disable implicit animations

    // Calculate dynamic scaling based on screen/view size
    let scaleFactor = calculateScaleFactor()
    let dynamicLineWidth = 4.0 * scaleFactor
    let dynamicCornerRadius = 6.0 * scaleFactor
    let dynamicFontSize = 14.0 * scaleFactor
    
    // Update line width
    shapeLayer.lineWidth = dynamicLineWidth
    
    let path = UIBezierPath(roundedRect: frame, cornerRadius: dynamicCornerRadius)
    shapeLayer.path = path.cgPath
    shapeLayer.strokeColor = color.withAlphaComponent(alpha).cgColor  // Apply color and alpha to the stroke
    shapeLayer.isHidden = false  // Make the shape layer visible

    // Update font size and font
    textLayer.fontSize = dynamicFontSize
    textLayer.font = UIFont(name: "Avenir", size: dynamicFontSize)
    textLayer.string = label  // Set the label text
    textLayer.backgroundColor = color.withAlphaComponent(alpha).cgColor  // Apply color and alpha to the background
    textLayer.isHidden = false  // Make the text layer visible
    textLayer.foregroundColor = UIColor.white.withAlphaComponent(alpha).cgColor  // Set text color

    // Calculate the text size and position based on the label content with dynamic sizing
    let font = UIFont(name: "Avenir", size: dynamicFontSize) ?? UIFont.systemFont(ofSize: dynamicFontSize)
    let attributes = [NSAttributedString.Key.font: font]
    let textRect = label.boundingRect(
      with: CGSize(width: 400 * scaleFactor, height: 100 * scaleFactor),
      options: .truncatesLastVisibleLine,
      attributes: attributes, context: nil)
    let padding = 12.0 * scaleFactor
    let textSize = CGSize(width: textRect.width + padding, height: textRect.height)
    let offset = 2.0 * scaleFactor
    let textOrigin = CGPoint(x: frame.origin.x - offset, y: frame.origin.y - textSize.height - offset)
    textLayer.frame = CGRect(origin: textOrigin, size: textSize)
  }
  
  /// Calculates scale factor based on screen size
  private func calculateScaleFactor() -> CGFloat {
    guard let parentView = parentView else {
      // Fallback to screen size if no parent view
      let screenSize = UIScreen.main.bounds.size
      let baseSize: CGFloat = 375.0 // iPhone reference size
      let rawScale = max(screenSize.width, screenSize.height) / baseSize
      // Use square root to reduce scaling for line width
      return max(1.0, min(sqrt(rawScale), 3.0))
    }
    
    let viewSize = parentView.bounds.size
    let baseSize: CGFloat = 375.0 // iPhone reference size
    let rawScale = max(viewSize.width, viewSize.height) / baseSize
    
    // Use square root to reduce scaling for line width and text
    let scaleFactor = sqrt(rawScale)
    
    // Clamp scale factor between reasonable bounds
    return max(1.0, min(scaleFactor, 3.0))
  }

  /// Hides the bounding box and text layers.
  func hide() {
    shapeLayer.isHidden = true
    textLayer.isHidden = true
  }
}

struct BoundingBoxInfo {
  var rect: CGRect
  var strokeColor: UIColor
  var strokeWidth: CGFloat
  var cornerRadius: CGFloat
  var alpha: CGFloat
  var labelText: String
  var labelFont: UIFont
  var labelTextColor: UIColor
  var labelBackgroundColor: UIColor
  var isHidden: Bool
}

@MainActor
func createBoxView(from info: BoundingBoxInfo) -> UIView {
  let boxView = UIView()
  boxView.layer.borderColor = info.strokeColor.withAlphaComponent(info.alpha).cgColor
  boxView.layer.borderWidth = info.strokeWidth
  boxView.layer.cornerRadius = info.cornerRadius
  boxView.backgroundColor = .clear

  let label = UILabel()
  label.text = info.labelText
  label.font = info.labelFont
  label.textColor = info.labelTextColor.withAlphaComponent(info.alpha)
  label.backgroundColor = info.labelBackgroundColor.withAlphaComponent(info.alpha)
  label.sizeToFit()

  let labelHeight = label.bounds.height
  label.frame.origin = CGPoint(x: 0, y: -labelHeight - 4)
  label.frame.size.width = max(label.frame.size.width, boxView.bounds.width)

  boxView.addSubview(label)

  return boxView
}

@MainActor
func makeBoundingBoxInfos(from boxViews: [BoundingBoxView]) -> [BoundingBoxInfo] {
  var results = [BoundingBoxInfo]()

  for box in boxViews {
    let shapeLayer = box.shapeLayer
    let textLayer = box.textLayer

    let hidden = (shapeLayer.isHidden && textLayer.isHidden)
    if !hidden {
      // 1) Get the bounding box CGRect from shapeLayer.path
      //    If shapeLayer.path is nil, use .zero
      let boundingRect: CGRect
      if let path = shapeLayer.path {
        boundingRect = path.boundingBox
      } else {
        boundingRect = .zero
      }

      // 2) Border color and opacity
      let strokeCGColor = shapeLayer.strokeColor ?? UIColor.clear.cgColor
      let strokeUI = UIColor(cgColor: strokeCGColor)
      // Extract alpha from strokeUI (strokeUI.cgColor.alpha also works)
      let strokeAlpha = strokeUI.cgColor.alpha

      // 3) Line width
      let lineWidth = shapeLayer.lineWidth

      // 4) Corner radius (using fixed value 6.0 to match BoundingBoxView)
      let cornerRadius: CGFloat = 6.0

      // 5) Get label text from text layer
      let labelString = (textLayer.string as? String) ?? ""

      // Text layer background color
      let labelBGCG = textLayer.backgroundColor ?? UIColor.clear.cgColor
      let labelBG = UIColor(cgColor: labelBGCG)

      // Text foreground color
      let fgCG = textLayer.foregroundColor ?? UIColor.white.cgColor
      let labelTextColor = UIColor(cgColor: fgCG)

      let fontSize = textLayer.fontSize
      let fontName = "Avenir"
      let labelFont = UIFont(name: fontName, size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

      let finalAlpha = strokeAlpha  // shapeLayerベース

      let info = BoundingBoxInfo(
        rect: boundingRect,
        strokeColor: strokeUI.withAlphaComponent(finalAlpha),
        strokeWidth: lineWidth,
        cornerRadius: cornerRadius,
        alpha: finalAlpha,
        labelText: labelString,
        labelFont: labelFont,
        labelTextColor: labelTextColor.withAlphaComponent(finalAlpha),
        labelBackgroundColor: labelBG.withAlphaComponent(finalAlpha),
        isHidden: hidden
      )
      results.append(info)
    }
  }

  return results

}
