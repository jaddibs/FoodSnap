import SwiftUI
import PhotosUI
import AVFoundation
import UIKit

// This extension adds Info.plist entries through code as an alternative approach
extension Bundle {
    // Make sure this key is included in build settings or Info.plist
    var cameraUsageDescription: String {
        return self.infoDictionary?["NSCameraUsageDescription"] as? String ?? 
               "FoodSnap needs camera access to take photos of food ingredients."
    }
    
    var photoLibraryUsageDescription: String {
        return self.infoDictionary?["NSPhotoLibraryUsageDescription"] as? String ?? 
               "FoodSnap needs photo library access to select images of food ingredients."
    }
}

// MARK: - Capture Button View
struct CaptureButton: View {
    let action: () -> Void
    let isDisabled: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Theme.Colors.primary)
                    )
                
                Text("Capture")
                    .font(Theme.Typography.callout.weight(.medium))
                    .foregroundColor(Theme.Colors.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .stroke(Theme.Colors.primary.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

// MARK: - Upload Button View
struct UploadButton: View {
    let photoItem: Binding<PhotosPickerItem?>
    let isDisabled: Bool
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        PhotosPicker(selection: photoItem, matching: .images) {
            VStack(spacing: 8) {
                Image(systemName: "photo.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Theme.Colors.accent)
                    )
                
                Text("Upload")
                    .font(Theme.Typography.callout.weight(.medium))
                    .foregroundColor(Theme.Colors.text)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.2) : Color.white)
                    .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                    .stroke(Theme.Colors.accent.opacity(0.5), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1)
    }
}

// MARK: - Photo Frame
struct PhotoFrame: View {
    @Environment(\.colorScheme) var colorScheme
    let images: [UIImage]
    let onDelete: ((Int) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: Theme.Dimensions.spacing) {
                ForEach(0..<3) { index in
                    ZStack {
                        // Background placeholder
                        RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                            .fill(colorScheme == .dark ? 
                                  Color.black.opacity(0.15) : 
                                  Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                                    .stroke(
                                        index < images.count ? 
                                            Theme.Colors.secondary : 
                                            Theme.Colors.secondary.opacity(0.3),
                                        lineWidth: 1.5
                                    )
                            )
                            .frame(width: 100, height: 100)
                        
                        // Photo if available
                        if index < images.count {
                            Image(uiImage: images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius))
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                                        .stroke(Theme.Colors.secondary, lineWidth: 1)
                                )
                            
                            // Delete button
                            if let onDelete = onDelete {
                                Button(action: { onDelete(index) }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .background(Color.black.opacity(0.5))
                                        .clipShape(Circle())
                                }
                                .padding(4)
                                .offset(x: 40, y: -40)
                            }
                        }
                    }
                }
            }
            
            // Image counter (always visible)
            Text("\(images.count)/3 images")
                .font(Theme.Typography.footnote)
                .foregroundColor(Theme.Colors.secondaryText)
        }
        .padding(Theme.Dimensions.horizontalPadding)
        .background(
            RoundedRectangle(cornerRadius: Theme.Dimensions.cornerRadius)
                .fill(colorScheme == .dark ? 
                      Color.black.opacity(0.2) : 
                      Color.white)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.2 : 0.05), radius: 6, x: 0, y: 2)
        )
        .padding(.horizontal, Theme.Dimensions.horizontalPadding)
    }
}

struct ImagePicker: View {
    @Binding var selectedImages: [UIImage]
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var cameraError: String? = nil
    @Environment(\.colorScheme) var colorScheme
    
    private let maxImages = 3
    
    var body: some View {
        VStack(spacing: Theme.Dimensions.largeSpacing) {
            // Image capture/upload buttons
            HStack(spacing: Theme.Dimensions.largeSpacing) {
                CaptureButton(
                    action: { checkCameraPermission() },
                    isDisabled: selectedImages.count >= maxImages
                )
                
                UploadButton(
                    photoItem: $photoItem,
                    isDisabled: selectedImages.count >= maxImages
                )
            }
            .padding(.horizontal, Theme.Dimensions.horizontalPadding)
            
            // Photo frame with placeholder or images
            PhotoFrame(
                images: selectedImages,
                onDelete: { index in
                    selectedImages.remove(at: index)
                }
            )
        }
        .sheet(isPresented: $showCamera) {
            EnhancedCameraView(onImageCaptured: { image in
                if let image = image {
                    selectedImages.append(image)
                }
            })
            .ignoresSafeArea()
            .onDisappear {
                cameraError = nil
            }
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
        } message: {
            Text(permissionMessage)
        }
        .alert("Camera Error", isPresented: Binding(
            get: { cameraError != nil },
            set: { if !$0 { cameraError = nil } }
        )) {
            Button("OK", role: .cancel) { cameraError = nil }
        } message: {
            Text(cameraError ?? "Unknown error")
        }
        .onChange(of: photoItem) { oldItem, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    if selectedImages.count < maxImages {
                        selectedImages.append(image)
                    }
                }
            }
        }
    }
    
    private func checkCameraPermission() {
        // Check if camera is available first
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            permissionMessage = "This device doesn't have a camera available."
            showPermissionAlert = true
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        showCamera = true
                    } else {
                        permissionMessage = "Camera access is required to take photos."
                        showPermissionAlert = true
                    }
                }
            }
        case .denied, .restricted:
            permissionMessage = "Camera access is required to take photos. Please enable it in Settings."
            showPermissionAlert = true
        @unknown default:
            permissionMessage = "Unknown camera permission status."
            showPermissionAlert = true
        }
    }
}

// MARK: - Enhanced Camera View
struct EnhancedCameraView: View {
    let onImageCaptured: (UIImage?) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            CameraViewControllerRepresentable(onImageCaptured: { image in
                onImageCaptured(image)
                presentationMode.wrappedValue.dismiss()
            }, onError: { error in
                errorMessage = error
                showingAlert = true
            })
            .ignoresSafeArea()
        }
        .alert("Camera Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text(errorMessage)
        }
    }
}

// MARK: - Camera View Controller
struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage?) -> Void
    let onError: (String) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        // Ensure camera is available and properly configured
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.cameraDevice = .rear  // Default to rear camera
            picker.allowsEditing = false // No editing after capture for simplicity
            picker.showsCameraControls = true // Show default camera controls
        } else {
            DispatchQueue.main.async {
                onError("Camera is not available on this device")
            }
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to update here
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraViewControllerRepresentable
        
        init(_ parent: CameraViewControllerRepresentable) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            } else {
                parent.onError("Failed to capture image")
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onImageCaptured(nil)
        }
    }
} 
