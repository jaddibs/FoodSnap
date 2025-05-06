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

struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var cameraError: String? = nil
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(12)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    checkCameraPermission()
                }) {
                    Label("Take Photo", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            EnhancedCameraView(selectedImage: $selectedImage)
                .ignoresSafeArea()
                .onDisappear {
                    // Reset camera error on dismiss if needed
                    cameraError = nil
                }
        }
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("OK", role: .cancel) { }
            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
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
                    selectedImage = image
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

// Enhanced camera view that properly sets up the camera session
struct EnhancedCameraView: View {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Use UIKit-based camera view controller
            CameraViewControllerRepresentable(selectedImage: $selectedImage, onComplete: {
                presentationMode.wrappedValue.dismiss()
            }, onError: { error in
                errorMessage = error
                showingAlert = true
            })
            .ignoresSafeArea()
            
            // Camera controls overlay could be added here if needed
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

// UIKit-based camera view controller with proper camera configuration
struct CameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onComplete: () -> Void
    var onError: (String) -> Void
    
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
                parent.selectedImage = image
                parent.onComplete()
            } else {
                parent.onError("Failed to capture image")
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onComplete()
        }
    }
} 
