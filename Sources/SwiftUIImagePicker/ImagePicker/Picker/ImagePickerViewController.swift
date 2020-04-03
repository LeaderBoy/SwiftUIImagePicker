//
//  ImagePickerViewController.swift
//  ImagePicker
//
//  Created by 杨 on 2020/4/1.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit
import Photos
import Localizable
/// Code from
/// https://developer.apple.com/documentation/photokit/browsing_and_modifying_photo_albums

private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}

extension ImagePickerViewController : Localizable {
    var key: String {
        return ImagePickerConstants.localizedPrefix + "NothingInside"
    }
    
    var value : String {
        return "Nothing inside"
    }
}

class ImagePickerViewController: UICollectionViewController {
    
    var folder : ImageFetcher.Folder!
    /// default is true
    /// if set false,first item at indexPath will not be camera
    var cameraEnable : Bool = true
    
    var selectedImage : UIImage? {
        didSet {
            onImagePicked(selectedImage)
        }
    }
    
    typealias OnImagePicker = (UIImage?) ->()
    
    var onImagePicked : OnImagePicker!
    
    fileprivate var collectionViewFlowLayout: UICollectionViewFlowLayout!
    fileprivate var availableWidth: CGFloat = 0
    fileprivate var itemSize : CGSize = .zero
    fileprivate var thumbnailSize: CGSize = CGSize(width: 100, height: 100)
    fileprivate var previousPreheatRect = CGRect.zero
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate let imageFetcher = ImageFetcher()
    fileprivate var fetchResult: PHFetchResult<PHAsset>?
    fileprivate var selectedIndexPath : IndexPath? {
        didSet {
            if selectedIndexPath == nil {
                selectedImage = nil
            } else {
                guard let asset = fetchResult?.object(at: selectedIndexPath!.row) else { return }
                fetchImage(from: asset, at: selectedIndexPath!)
            }
        }
    }
    
    lazy var imagePickerController: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        return imagePicker
    }()
    
    lazy var label: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.lightGray
        l.text = self.local
        l.font = UIFont.boldSystemFont(ofSize: 25)
        l.sizeToFit()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(l)
        
        NSLayoutConstraint.activate([
            l.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            l.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            l.topAnchor.constraint(equalTo: view.topAnchor),
            l.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        return l
    }()

    init() {
        collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.minimumLineSpacing = 5
        collectionViewFlowLayout.minimumInteritemSpacing = 2.5
        super.init(collectionViewLayout: collectionViewFlowLayout)
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
          PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetCachedAssets()
        setupCollectionView()
        fetchAssets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachedAssets()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let width = view.bounds.inset(by: view.safeAreaInsets).width
        // Adjust the item size if the available width has changed.
        if availableWidth != width {
            availableWidth = width
            let spacing = collectionViewFlowLayout.minimumInteritemSpacing * 2
            let margin = collectionView.contentInset.left + collectionView.contentInset.right
            let column = columnLayout(for: width)
            
            let itemLength = (((availableWidth - margin - CGFloat(column - 1) * spacing)) / CGFloat(column)).rounded(.towardZero) 
            let itemSize = CGSize(width: itemLength, height: itemLength)
            self.itemSize = itemSize
            collectionViewFlowLayout.itemSize = itemSize
            // Determine the size of the thumbnails to request from the PHCachingImageManager.
            let scale = UIScreen.main.scale
            thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
        }
    }
    
    func refreshLabel() {
        if let result = fetchResult,result.count != 0 {
            label.isHidden = true
        } else {
            label.isHidden = false
        }
    }
    
    func fetchAssets() {
        fetchResult = imageFetcher.fetchAssets(in: folder, with: nil)
        refreshLabel()
    }
    
    func columnLayout(for width : CGFloat) -> Int {
        if width < 200 {
            return 2
        } else if width < 375 {
            return 3
        }else if width < 500 {
            return 4
        } else {
            return 6
        }
    }
    
    func setupCollectionView() {
        collectionView.allowsMultipleSelection = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ImagePickerCell.self, forCellWithReuseIdentifier: ImagePickerCell.reusedID)
        
        if cameraEnable {
            collectionView.register(ImagePickerCameraCell.self, forCellWithReuseIdentifier: ImagePickerCameraCell.reusedID)
        }
    }
    
    fileprivate func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
    
    /// - Tag: UpdateAssets
    fileprivate func updateCachedAssets() {
        
        // Update only if the view is visible.
        guard isViewLoaded && view.window != nil else { return }
        
        guard let fetchResult = fetchResult else { return }
        
        // The window you prepare ahead of time is twice the height of the visible rect.
        let visibleRect = CGRect(origin: collectionView!.contentOffset, size: collectionView!.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // Update only if the visible area is significantly different from the last preheated area.
        let delta = abs(preheatRect.midY - previousPreheatRect.midY)
        guard delta > view.bounds.height / 3 else { return }
        
        // Compute the assets to start and stop caching.
        let (addedRects, removedRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        let removedAssets = removedRects
            .flatMap { rect in collectionView!.indexPathsForElements(in: rect) }
            .map { indexPath in fetchResult.object(at: indexPath.item) }
        
        // Update the assets the PHCachingImageManager is caching.
        imageManager.startCachingImages(for: addedAssets,
                                        targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets,
                                       targetSize: thumbnailSize, contentMode: .aspectFill, options: nil)
        // Store the computed rectangle for future comparison.
        previousPreheatRect = preheatRect
    }
    
    fileprivate func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        if old.intersects(new) {
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY,
                                 width: new.width, height: new.maxY - old.maxY)]
            }
            if old.minY > new.minY {
                added += [CGRect(x: new.origin.x, y: new.minY,
                                 width: new.width, height: old.minY - new.minY)]
            }
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY,
                                   width: new.width, height: old.maxY - new.maxY)]
            }
            if old.minY < new.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY,
                                   width: new.width, height: new.minY - old.minY)]
            }
            return (added, removed)
        } else {
            return ([new], [old])
        }
    }
    
}

extension ImagePickerViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if fetchResult == nil {
            return 0
        }
        return fetchResult!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if cameraEnable && indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCameraCell.reusedID, for: indexPath) as! ImagePickerCameraCell
            
            cell.buttonClicked = { [weak self] in
                guard let self = self else { return }
                self.showCamera()
            }
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagePickerCell.reusedID, for: indexPath) as! ImagePickerCell
        cell.itemSize = itemSize

        if let asset = fetchResult?.object(at: indexPath.item) {
            cell.representedAssetIdentifier  = asset.localIdentifier
            imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil) { (image, _) in
                if cell.representedAssetIdentifier == asset.localIdentifier {
                    cell.image = image
                }
            }
        }
        return cell
    }
    
    /// Single cell selected
    /// https://stackoverflow.com/questions/45373118/diddeselectitemat-indexpath-doesnt-triggered-when-another-cell-is-selected?rq=1
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previousSelectedIndexPath = selectedIndexPath {
            if previousSelectedIndexPath == indexPath {
                collectionView.deselectItem(at: indexPath, animated: false)
                selectedIndexPath = nil
            } else {
                UIView.performWithoutAnimation {
                    collectionView.reloadItems(at: [previousSelectedIndexPath])
                }
                selectedIndexPath = indexPath
            }
        } else {
            selectedIndexPath = indexPath
        }
        
        
    }
    
    
    func fetchImage(from asset : PHAsset,at indexPath : IndexPath) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options) { (image, _) in
            self.selectedImage = image
        }
    }
}

extension ImagePickerViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate  {
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(imagePickerController, animated: true, completion: nil)
        } else {
            print("Camera is not available")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
        } else {
            print("EditedImage is nil")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension ImagePickerViewController : PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            if let result = self.fetchResult,let changeDetails = changeInstance.changeDetails(for: result) {
                self.fetchResult = changeDetails.fetchResultAfterChanges
                self.refreshLabel()
            }
        }
    }
}

extension ImagePickerViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
}
