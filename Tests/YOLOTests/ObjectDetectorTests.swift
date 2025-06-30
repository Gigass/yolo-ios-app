// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import XCTest
import Vision
import CoreML
@testable import YOLO

/// Comprehensive tests for ObjectDetector functionality
class ObjectDetectorTests: XCTestCase {
    
    var detector: ObjectDetector!
    
    override func setUp() {
        super.setUp()
        detector = ObjectDetector()
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testObjectDetectorInitialization() {
        // Verify ObjectDetector inherits proper initialization from BasePredictor
        XCTAssertFalse(detector.isModelLoaded)
        XCTAssertEqual(detector.labels.count, 0)
        XCTAssertEqual(detector.confidenceThreshold, 0.25, accuracy: 0.001)
        XCTAssertEqual(detector.iouThreshold, 0.4, accuracy: 0.001)
        XCTAssertEqual(detector.numItemsThreshold, 30)
    }
    
    // MARK: - Threshold Configuration Tests
    
    func testSetConfidenceThreshold() {
        // Test confidence threshold setting
        detector.setConfidenceThreshold(confidence: 0.6)
        XCTAssertEqual(detector.confidenceThreshold, 0.6, accuracy: 0.001)
        
        // Test boundary values
        detector.setConfidenceThreshold(confidence: 0.0)
        XCTAssertEqual(detector.confidenceThreshold, 0.0, accuracy: 0.001)
        
        detector.setConfidenceThreshold(confidence: 1.0)
        XCTAssertEqual(detector.confidenceThreshold, 1.0, accuracy: 0.001)
    }
    
    func testSetIouThreshold() {
        // Test IoU threshold setting
        detector.setIouThreshold(iou: 0.7)
        XCTAssertEqual(detector.iouThreshold, 0.7, accuracy: 0.001)
        
        // Test boundary values
        detector.setIouThreshold(iou: 0.0)
        XCTAssertEqual(detector.iouThreshold, 0.0, accuracy: 0.001)
        
        detector.setIouThreshold(iou: 1.0)
        XCTAssertEqual(detector.iouThreshold, 1.0, accuracy: 0.001)
    }
    
    // MARK: - Process Observations Tests
    
    func testProcessObservationsWithEmptyResults() {
        // Test processing with no detections
        let request = MockVNRequestWithResults(results: [])
        
        let expectation = XCTestExpectation(description: "Process empty observations")
        
        // Set up listener to capture results
        detector.setOnResultsListener { result in
            XCTAssertEqual(result.boxes.count, 0)
            XCTAssertGreaterThan(result.fps, 0)
            expectation.fulfill()
        }
        
        detector.processObservations(for: request, error: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessObservationsWithDetections() {
        // Test processing with multiple detections
        detector.labels = ["person", "car", "dog", "cat", "bicycle"]
        detector.inputSize = CGSize(width: 640, height: 480)
        
        let mockObservations = createMockObservations()
        let request = MockVNRequestWithResults(results: mockObservations)
        
        let expectation = XCTestExpectation(description: "Process observations with detections")
        
        detector.setOnResultsListener { result in
            XCTAssertEqual(result.boxes.count, 3)
            
            // Check first detection
            let firstBox = result.boxes[0]
            XCTAssertEqual(firstBox.cls, "person")
            XCTAssertEqual(firstBox.conf, 0.95, accuracy: 0.001)
            XCTAssertEqual(firstBox.index, 0)
            
            // Check second detection
            let secondBox = result.boxes[1]
            XCTAssertEqual(secondBox.cls, "car")
            XCTAssertEqual(secondBox.conf, 0.85, accuracy: 0.001)
            XCTAssertEqual(secondBox.index, 1)
            
            expectation.fulfill()
        }
        
        detector.processObservations(for: request, error: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessObservationsWithNumItemsThreshold() {
        // Test that numItemsThreshold limits the number of results
        detector.labels = ["person", "car", "dog"]
        detector.numItemsThreshold = 2
        
        let mockObservations = createManyMockObservations(count: 5)
        let request = MockVNRequestWithResults(results: mockObservations)
        
        let expectation = XCTestExpectation(description: "Process observations with item threshold")
        
        detector.setOnResultsListener { result in
            XCTAssertEqual(result.boxes.count, 2) // Should be limited by numItemsThreshold
            expectation.fulfill()
        }
        
        detector.processObservations(for: request, error: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testProcessObservationsPerformanceMetrics() {
        // Test that performance metrics are calculated
        let request = MockVNRequestWithResults(results: [])
        
        let inferenceExpectation = XCTestExpectation(description: "Inference time callback")
        
        detector.setOnInferenceTimeListener { inferenceTime, fpsRate in
            XCTAssertGreaterThanOrEqual(inferenceTime, 0)
            XCTAssertGreaterThan(fpsRate, 0)
            inferenceExpectation.fulfill()
        }
        
        detector.processObservations(for: request, error: nil)
        
        wait(for: [inferenceExpectation], timeout: 1.0)
    }
    
    // MARK: - Predict on Image Tests
    
    func testPredictOnImageWithNoModel() {
        // Test prediction when no model is loaded
        let image = createTestImage()
        
        let result = detector.predictOnImage(image: image)
        
        XCTAssertEqual(result.boxes.count, 0)
        XCTAssertEqual(result.speed, 0, accuracy: 0.001)
        XCTAssertEqual(result.orig_shape, detector.inputSize)
    }
    
    func testPredictOnImageSetsInputSize() {
        // Test that predictOnImage properly sets input size
        let image = createTestImage(width: 800, height: 600)
        
        _ = detector.predictOnImage(image: image)
        
        XCTAssertEqual(detector.inputSize.width, 800)
        XCTAssertEqual(detector.inputSize.height, 600)
    }
    
    func testPredictOnImageWithMockVisionRequest() {
        // Test prediction with a mock vision request
        detector.labels = ["person", "car", "dog"]
        
        // Create a mock vision request that returns results
        let mockObservations = createMockObservations()
        let mockRequest = MockVNCoreMLRequest(results: mockObservations)
        detector.visionRequest = mockRequest
        
        let image = createTestImage()
        let result = detector.predictOnImage(image: image)
        
        XCTAssertEqual(result.boxes.count, 3)
        XCTAssertNotNil(result.annotatedImage)
        XCTAssertEqual(result.names, ["person", "car", "dog"])
    }
    
    // MARK: - Box Coordinate Conversion Tests
    
    func testBoundingBoxCoordinateConversion() {
        // Test that bounding boxes are properly converted from normalized to image coordinates
        detector.labels = ["test"]
        detector.inputSize = CGSize(width: 1000, height: 500)
        
        let normalizedBox = CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        let mockObservation = MockVNRecognizedObjectObservation(
            boundingBox: normalizedBox,
            labels: [MockVNClassificationObservation(identifier: "test", confidence: 0.9)]
        )
        
        let request = MockVNRequestWithResults(results: [mockObservation])
        
        let expectation = XCTestExpectation(description: "Check coordinate conversion")
        
        detector.setOnResultsListener { result in
            guard let box = result.boxes.first else {
                XCTFail("No boxes found")
                return
            }
            
            // Check that coordinates were properly inverted and scaled
            // Y coordinate should be inverted: 1 - (0.2 + 0.4) = 0.4
            let expectedY = (1 - 0.6) * 500 // 200
            let expectedX = 0.1 * 1000 // 100
            let expectedWidth = 0.3 * 1000 // 300
            let expectedHeight = 0.4 * 500 // 200
            
            XCTAssertEqual(box.xywh.origin.x, expectedX, accuracy: 1.0)
            XCTAssertEqual(box.xywh.origin.y, expectedY, accuracy: 1.0)
            XCTAssertEqual(box.xywh.width, expectedWidth, accuracy: 1.0)
            XCTAssertEqual(box.xywh.height, expectedHeight, accuracy: 1.0)
            
            expectation.fulfill()
        }
        
        detector.processObservations(for: request, error: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testProcessObservationsWithError() {
        // Test that errors are handled gracefully
        let request = MockVNRequestWithResults(results: [])
        let error = NSError(domain: "TestError", code: 100, userInfo: nil)
        
        // Should not crash
        detector.processObservations(for: request, error: error)
    }
    
    func testProcessObservationsWithWrongResultType() {
        // Test handling of unexpected result types
        let request = MockVNRequestWithResults(results: ["Not a VNRecognizedObjectObservation"])
        
        // Should not crash or process results
        detector.processObservations(for: request, error: nil)
    }
    
    // MARK: - Integration Tests
    
    func testEndToEndObjectDetection() {
        // Test complete object detection flow
        detector.labels = ["person", "bicycle", "car", "motorcycle", "airplane"]
        detector.setConfidenceThreshold(confidence: 0.5)
        detector.setIouThreshold(iou: 0.6)
        
        let mockObservations = [
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: 0.1, y: 0.1, width: 0.2, height: 0.3),
                labels: [MockVNClassificationObservation(identifier: "person", confidence: 0.9)]
            ),
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: 0.5, y: 0.5, width: 0.3, height: 0.2),
                labels: [MockVNClassificationObservation(identifier: "car", confidence: 0.8)]
            ),
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: 0.2, y: 0.6, width: 0.1, height: 0.1),
                labels: [MockVNClassificationObservation(identifier: "bicycle", confidence: 0.4)] // Below threshold
            )
        ]
        
        let request = MockVNRequestWithResults(results: mockObservations)
        
        let expectation = XCTestExpectation(description: "End to end detection")
        
        detector.setOnResultsListener { result in
            // Only 2 detections should pass the confidence threshold
            XCTAssertEqual(result.boxes.count, 2)
            XCTAssertEqual(result.names.count, 5)
            XCTAssertGreaterThan(result.fps, 0)
            XCTAssertGreaterThanOrEqual(result.speed, 0)
            
            // Verify boxes are sorted by confidence
            if result.boxes.count >= 2 {
                XCTAssertGreaterThan(result.boxes[0].conf, result.boxes[1].conf)
            }
            
            expectation.fulfill()
        }
        
        detector.processObservations(for: request, error: nil)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(width: CGFloat = 640, height: CGFloat = 480) -> CIImage {
        return CIImage(color: .blue).cropped(to: CGRect(x: 0, y: 0, width: width, height: height))
    }
    
    private func createMockObservations() -> [VNRecognizedObjectObservation] {
        return [
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: 0.1, y: 0.2, width: 0.3, height: 0.4),
                labels: [MockVNClassificationObservation(identifier: "person", confidence: 0.95)]
            ),
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: 0.5, y: 0.1, width: 0.2, height: 0.3),
                labels: [MockVNClassificationObservation(identifier: "car", confidence: 0.85)]
            ),
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: 0.7, y: 0.6, width: 0.2, height: 0.2),
                labels: [MockVNClassificationObservation(identifier: "dog", confidence: 0.75)]
            )
        ]
    }
    
    private func createManyMockObservations(count: Int) -> [VNRecognizedObjectObservation] {
        return (0..<count).map { i in
            MockVNRecognizedObjectObservation(
                boundingBox: CGRect(x: Double(i) * 0.1, y: 0.1, width: 0.1, height: 0.1),
                labels: [MockVNClassificationObservation(identifier: "person", confidence: Float(90 - i) / 100)]
            )
        }
    }
}

// MARK: - Mock Classes

class MockVNRequestWithResults: VNRequest, @unchecked Sendable {
    private var mockResults: [VNObservation]?
    
    init(results: [Any]) {
        super.init(completionHandler: nil)
        // Convert Any results to VNObservation
        self.mockResults = results.compactMap { $0 as? VNObservation }
    }
    
    override var results: [VNObservation]? {
        return mockResults
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MockVNCoreMLRequest: VNCoreMLRequest, @unchecked Sendable {
    private var mockResults: [VNObservation]?
    
    init(results: [Any]) {
        // Create a dummy model for initialization
        let config = MLModelConfiguration()
        if let dummyModel = try? MLModel(contentsOf: Bundle.main.bundleURL, configuration: config) {
            super.init(model: dummyModel)
        } else {
            // If we can't create a dummy model, we need to handle this differently
            // This is a limitation of testing CoreML requests
            fatalError("Cannot create mock VNCoreMLRequest without a valid model")
        }
        self.mockResults = results.compactMap { $0 as? VNObservation }
    }
    
    override var results: [VNObservation]? {
        return mockResults
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MockVNRecognizedObjectObservation: VNRecognizedObjectObservation {
    private let mockBoundingBox: CGRect
    private let mockLabels: [VNClassificationObservation]
    
    init(boundingBox: CGRect, labels: [VNClassificationObservation]) {
        self.mockBoundingBox = boundingBox
        self.mockLabels = labels
        super.init()
    }
    
    override var boundingBox: CGRect {
        return mockBoundingBox
    }
    
    override var labels: [VNClassificationObservation] {
        return mockLabels
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MockVNClassificationObservation: VNClassificationObservation {
    private let mockIdentifier: String
    private let mockConfidence: VNConfidence
    
    init(identifier: String, confidence: VNConfidence) {
        self.mockIdentifier = identifier
        self.mockConfidence = confidence
        super.init()
    }
    
    override var identifier: String {
        return mockIdentifier
    }
    
    override var confidence: VNConfidence {
        return mockConfidence
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}