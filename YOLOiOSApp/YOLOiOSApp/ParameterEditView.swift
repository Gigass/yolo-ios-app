// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import UIKit

class ParameterEditView: UIView {
    enum Parameter {
        case itemsMax(Int)
        case confidence(Float)
        case iou(Float)
        case lineThickness(Float)
        
        var title: String {
            switch self {
            case .itemsMax: return "ITEMS MAX"
            case .confidence: return "CONFIDENCE THRESHOLD"
            case .iou: return "IoU THRESHOLD"
            case .lineThickness: return "LINE THICKNESS"
            }
        }
        
        var range: ClosedRange<Float> {
            switch self {
            case .itemsMax: return 1...30
            case .confidence, .iou: return 0...1
            case .lineThickness: return 0.5...3.0
            }
        }
        
        var step: Float {
            switch self {
            case .itemsMax: return 1
            case .confidence, .iou: return 0.02
            case .lineThickness: return 0.1
            }
        }
        
        var value: Float {
            switch self {
            case .itemsMax(let v): return Float(v)
            case .confidence(let v), .iou(let v), .lineThickness(let v): return v
            }
        }
    }
    
    private let toastView = UIView()
    private let toastLabel = UILabel()
    private let slider = UISlider()
    private var hideTimer: Timer?
    private let tickStackView = UIStackView()
    private let labelStackView = UIStackView()
    private let sliderContainer = UIView()
    
    var onValueChange: ((Parameter) -> Void)?
    private var currentParameter: Parameter?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        // Allow touches to pass through when not showing controls
        isUserInteractionEnabled = false
        
        // Toast View
        toastView.backgroundColor = UIColor.ultralyticsBrown.withAlphaComponent(0.95)
        toastView.layer.cornerRadius = 14
        toastView.alpha = 0
        
        toastLabel.textColor = .ultralyticsTextPrimary
        toastLabel.font = Typography.toastFont
        toastLabel.textAlignment = .center
        
        toastView.addSubview(toastLabel)
        addSubview(toastView)
        
        // Slider container with background
        sliderContainer.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        sliderContainer.layer.cornerRadius = 12
        sliderContainer.alpha = 0
        
        // Slider
        slider.minimumTrackTintColor = .ultralyticsLime
        slider.maximumTrackTintColor = UIColor.gray.withAlphaComponent(0.4)
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        // Custom thumb
        let thumbSize: CGFloat = 28
        let thumbView = UIView(frame: CGRect(x: 0, y: 0, width: thumbSize, height: thumbSize))
        thumbView.backgroundColor = .white
        thumbView.layer.cornerRadius = thumbSize / 2
        thumbView.layer.shadowColor = UIColor.black.cgColor
        thumbView.layer.shadowOpacity = 0.15
        thumbView.layer.shadowOffset = CGSize(width: 0, height: 2)
        thumbView.layer.shadowRadius = 4
        
        // Add center dot
        let centerDot = UIView(frame: CGRect(x: (thumbSize - 12) / 2, y: (thumbSize - 12) / 2, width: 12, height: 12))
        centerDot.backgroundColor = .ultralyticsLime
        centerDot.layer.cornerRadius = 6
        thumbView.addSubview(centerDot)
        
        UIGraphicsBeginImageContextWithOptions(thumbView.bounds.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            thumbView.layer.render(in: context)
            let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            slider.setThumbImage(thumbImage, for: .normal)
            slider.setThumbImage(thumbImage, for: .highlighted)
        }
        
        // Tick marks
        tickStackView.axis = .horizontal
        tickStackView.distribution = .equalSpacing
        tickStackView.alignment = .center
        tickStackView.alpha = 0
        
        // Labels
        labelStackView.axis = .horizontal
        labelStackView.distribution = .equalSpacing
        labelStackView.alignment = .center
        labelStackView.alpha = 0
        
        sliderContainer.addSubview(slider)
        addSubview(sliderContainer)
        addSubview(tickStackView)
        addSubview(labelStackView)
        
        // Layout
        [toastView, toastLabel, slider, sliderContainer, tickStackView, labelStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Toast
            toastView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            toastView.centerXAnchor.constraint(equalTo: centerXAnchor),
            toastView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            toastView.heightAnchor.constraint(equalToConstant: 28),
            
            toastLabel.leadingAnchor.constraint(equalTo: toastView.leadingAnchor, constant: 12),
            toastLabel.trailingAnchor.constraint(equalTo: toastView.trailingAnchor, constant: -12),
            toastLabel.centerYAnchor.constraint(equalTo: toastView.centerYAnchor),
            
            // Slider container
            sliderContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            sliderContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            sliderContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -60),
            sliderContainer.heightAnchor.constraint(equalToConstant: 60),
            
            // Slider inside container
            slider.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor, constant: 16),
            slider.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor, constant: -16),
            slider.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor),
            slider.heightAnchor.constraint(equalToConstant: 44),
            
            // Tick marks
            tickStackView.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            tickStackView.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            tickStackView.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
            tickStackView.heightAnchor.constraint(equalToConstant: 12),
            
            // Labels
            labelStackView.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            labelStackView.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            labelStackView.topAnchor.constraint(equalTo: sliderContainer.bottomAnchor, constant: 8),
            labelStackView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func showParameter(_ parameter: Parameter) {
        currentParameter = parameter
        
        // Enable interaction when showing controls
        isUserInteractionEnabled = true
        
        // Configure slider
        slider.minimumValue = parameter.range.lowerBound
        slider.maximumValue = parameter.range.upperBound
        slider.value = parameter.value
        
        // Setup tick marks and labels
        setupTickMarks(for: parameter)
        
        // Update toast
        updateToastLabel()
        
        // Show with animation
        UIView.animate(withDuration: 0.15) {
            self.toastView.alpha = 1
            self.sliderContainer.alpha = 1
            self.tickStackView.alpha = 1
            self.labelStackView.alpha = 1
        }
        
        // Don't auto-hide - wait for user action
        hideTimer?.invalidate()
    }
    
    private func setupTickMarks(for parameter: Parameter) {
        // Clear existing marks
        tickStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        labelStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let tickCount = 5
        let labels: [String]
        
        switch parameter {
        case .confidence, .iou:
            labels = ["0", "25", "50", "75", "100"]
        case .itemsMax:
            labels = ["1", "8", "15", "23", "30"]
        case .lineThickness:
            labels = ["0.5", "1.0", "1.5", "2.0", "3.0"]
        }
        
        // Create tick marks and labels
        for i in 0..<tickCount {
            // Tick mark
            let tickView = UIView()
            tickView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
            tickView.translatesAutoresizingMaskIntoConstraints = false
            tickView.widthAnchor.constraint(equalToConstant: 2).isActive = true
            tickView.heightAnchor.constraint(equalToConstant: 12).isActive = true
            tickStackView.addArrangedSubview(tickView)
            
            // Label
            let label = UILabel()
            label.text = labels[i]
            label.font = .systemFont(ofSize: 12, weight: .medium)
            label.textColor = UIColor.white.withAlphaComponent(0.7)
            label.textAlignment = .center
            labelStackView.addArrangedSubview(label)
        }
    }
    
    @objc private func sliderValueChanged() {
        guard let parameter = currentParameter else { return }
        
        // Snap to step
        let step = parameter.step
        let roundedValue = round(slider.value / step) * step
        slider.value = roundedValue
        
        // Update parameter
        let newParameter: Parameter
        switch parameter {
        case .itemsMax:
            newParameter = .itemsMax(Int(roundedValue))
        case .confidence:
            newParameter = .confidence(roundedValue)
        case .iou:
            newParameter = .iou(roundedValue)
        case .lineThickness:
            newParameter = .lineThickness(roundedValue)
        }
        
        currentParameter = newParameter
        updateToastLabel()
        onValueChange?(newParameter)
        
        resetHideTimer()
    }
    
    private func updateToastLabel() {
        guard let parameter = currentParameter else { return }
        
        let valueText: String
        switch parameter {
        case .itemsMax(let v):
            valueText = "\(parameter.title): \(v)"
        case .confidence(let v), .iou(let v):
            valueText = String(format: "%@: %.2f", parameter.title, v)
        case .lineThickness(let v):
            valueText = String(format: "%@: %.1f", parameter.title, v)
        }
        
        toastLabel.text = valueText
    }
    
    private func resetHideTimer() {
        // No longer auto-hide - user must tap button or outside to dismiss
    }
    
    func hide() {
        hideTimer?.invalidate()
        
        UIView.animate(withDuration: 0.3) {
            self.toastView.alpha = 0
            self.sliderContainer.alpha = 0
            self.tickStackView.alpha = 0
            self.labelStackView.alpha = 0
        } completion: { _ in
            // Disable interaction when hidden
            self.isUserInteractionEnabled = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // If touch is outside the slider container, hide the parameter editor
        if !sliderContainer.frame.contains(location) {
            hide()
        }
    }
}