//
//  ImagePickerCell.swift
//  ImagePicker
//
//  Created by 杨 on 2020/3/30.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

class ImagePickerCell: UICollectionViewCell {
    
    static let reusedID = "ImagePickerCell"
    
    private let imageView = UIImageView()
    private let anchorImageView = UIImageView()

    var itemSize : CGSize = .zero
    
    var image : UIImage? {
        didSet {
            if let image = image {
                if let newImage = image.quickRoundCornerRadius(8, size: itemSize) {
                    imageView.image = newImage
                } else {
                    imageView.image = image
                }
            }
        }
    }
    
    var representedAssetIdentifier: String!

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.alpha = 0.6
                anchorImageView.image = #imageLiteral(resourceName: "imagePicker_selected")
            } else {
                imageView.alpha = 1.0
                anchorImageView.image = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
        
        anchorImageView.translatesAutoresizingMaskIntoConstraints = false
        anchorImageView.contentMode = .scaleAspectFit
        contentView.addSubview(anchorImageView)
        NSLayoutConstraint.activate([
            anchorImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -5),
            anchorImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -5),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIImage {
    func quickRoundCornerRadius(_ radius : CGFloat,size : CGSize) -> UIImage? {
        if size == .zero {
            return self
        }
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        if let context = UIGraphicsGetCurrentContext() {
            let path = UIBezierPath(roundedRect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
            context.addPath(path.cgPath)
            context.clip()
            draw(in: rect)
            context.drawPath(using: .fillStroke)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        return nil
    }
}
