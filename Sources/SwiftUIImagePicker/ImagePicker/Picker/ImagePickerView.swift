//
//  ImagePickerView.swift
//  ImagePicker
//
//  Created by 杨 on 2020/3/30.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import SwiftUI
import Combine
import Photos

public struct ImagePickerConstants {
    /// localized prefix
    /// used for load localized string from Localizable.strings
    static let localizedPrefix = "ImagePickerView_"
}

public struct ImagePickerView: View {
    @Binding public var currentPage : Int
    @Binding public var selectedImage : UIImage?
    public var folders : [ImageFetcher.Folder]
    public var barItems : [PageBarItem]
    
    @State private var progress : CGFloat = 0
    
    public init(currentPage: Binding<Int>, selectedImage: Binding<UIImage?>, folders: [ImageFetcher.Folder], barItems: [PageBarItem]) {
        self._currentPage = currentPage
        self._selectedImage = selectedImage
        self.folders = folders
        self.barItems = barItems
    }
    
    public var body: some View {
        VStack {
            PageView(currentPage: $currentPage, progress: $progress, views: createFoldersView())
            PagerBar(currentPage: $currentPage, progress: $progress, items: barItems)
            .frame(height: 60)
        }
        
    }
    
    func createFoldersView() -> [ImagePickerCollectionView] {
        var views : [ImagePickerCollectionView] = []
        for (index,folder) in folders.enumerated() {
            views.append(ImagePickerCollectionView(folder: folder, cameraEnable: index == 0, selectedImage: $selectedImage))
        }
        return views
    }
    
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(currentPage: .constant(0), selectedImage: .constant(nil), folders: [.all,.cameralRoll], barItems: [
            PageBarItem(title: "All"),
            PageBarItem(title: "CameralRoll")
        ])
    }
}
