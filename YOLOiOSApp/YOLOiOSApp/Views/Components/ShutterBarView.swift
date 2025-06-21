// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import SwiftUI
import PhotosUI

struct ShutterBarView: View {
    @ObservedObject var viewModel: YOLOViewModel
    @State private var showImagePicker = false
    @State private var photoPickerItem: PhotosPickerItem?
    
    var body: some View {
        HStack(spacing: 0) {
            // Gallery button
            Button(action: {
                showImagePicker = true
            }) {
                Group {
                    if let thumbnail = viewModel.lastThumbnail {
                        Image(uiImage: thumbnail)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            // Center section with capture/record button
            ZStack {
                // Recording indicator
                if viewModel.isRecording {
                    Circle()
                        .stroke(Color.red, lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isRecording)
                }
                
                // Main capture button
                Button(action: {
                    if viewModel.isVideoMode {
                        viewModel.toggleRecording()
                    } else {
                        viewModel.capturePhoto()
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(viewModel.isVideoMode ? Color.red : Color.white)
                            .frame(width: viewModel.isRecording ? 50 : 70, height: viewModel.isRecording ? 50 : 70)
                        
                        if viewModel.isVideoMode && viewModel.isRecording {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                                .frame(width: 20, height: 20)
                        }
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.isRecording)
            }
            .frame(width: 120)
            
            // Mode toggle and camera switch
            HStack(spacing: 24) {
                // Photo/Video toggle
                Button(action: {
                    viewModel.toggleCaptureMode()
                }) {
                    Image(systemName: viewModel.isVideoMode ? "video.fill" : "camera.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
                
                // Camera switch
                Button(action: {
                    viewModel.switchCamera()
                }) {
                    Image(systemName: "camera.rotate")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .frame(height: 100)
        .background(Color.ultralyticsSurfaceDark)
        .photosPicker(
            isPresented: $showImagePicker,
            selection: $photoPickerItem,
            matching: .images
        )
        .onChange(of: photoPickerItem) { newItem in
            Task {
                if let newItem = newItem {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run {
                            viewModel.processSelectedImage(image)
                        }
                    }
                }
            }
        }
    }
}