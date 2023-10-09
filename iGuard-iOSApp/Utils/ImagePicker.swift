//
//  ImagePicker.swift
//  SignInAndSignUp
//
//  Created by Aidar Asanakunov on 15/3/23.
//

import SwiftUI

@MainActor
struct ImagePicker: UIViewControllerRepresentable {
    @EnvironmentObject var homeViewModel: HomeViewModel
    
    @Binding var image: UIImage?
    let imageType: FolderPath
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var documentsViewModel: DocumentsViewModel
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    let isForProfileView: Bool
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate , UIImagePickerControllerDelegate {
        let parent: ImagePicker
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else { return }
            parent.image = image
            parent.presentationMode.wrappedValue.dismiss()
            if parent.isForProfileView { 
                parent.documentsViewModel.uploadImageStorage(path: parent.imageType, image: image) { result in
                    if result {
                        DispatchQueue.main.async {
                            self.parent.documentsViewModel.loadImageUrl()
                            self.parent.homeViewModel.getDocuments()
                        }
                    }
                }
            }
        }
    }
}
