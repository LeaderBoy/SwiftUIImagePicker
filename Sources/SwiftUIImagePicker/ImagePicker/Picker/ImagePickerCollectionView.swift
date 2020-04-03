//
//  ImagePickerCollectionView.swift
//  ImagePicker
//
//  Created by 杨 on 2020/3/30.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import SwiftUI
import Photos

enum ImagePickerSession {
    case all
    case favorites
    case videos
    case livePhoto
}

extension ImagePickerSession: Hashable {}

struct ImagePickerCollectionView: UIViewControllerRepresentable {
    var folder : ImageFetcher.Folder
    var cameraEnable = false
    @Binding var selectedImage : UIImage?
    
    let controller = ImagePickerViewController()
    
    func makeCoordinator() -> ImagePickerCollectionView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> ImagePickerViewController {
        controller.folder = folder
        controller.cameraEnable = cameraEnable
        controller.onImagePicked = { image in
            self.selectedImage = image
        }
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ImagePickerViewController, context: Context) {

    }
    
    class Coordinator: NSObject {
        let parent : ImagePickerCollectionView
        init(_ parent : ImagePickerCollectionView) {
            self.parent = parent
        }
    }
}

//struct ImagePickerCollectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerCollectionView(snapshot: .constant(NSDiffableDataSourceSnapshot<ImagePickerSession, ImagePickerAsset>()))
//    }
//}
