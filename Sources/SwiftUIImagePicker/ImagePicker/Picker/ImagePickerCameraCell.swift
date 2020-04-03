//
//  ImagePickerCameraCell.swift
//  ImagePicker
//
//  Created by 杨 on 2020/4/2.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

class ImagePickerCameraCell: UICollectionViewCell {
    
    static let reusedID = "ImagePickerCameraCell"
    
    private let imageView = UIButton(type: .system)
    
    typealias ButtonClicked = () -> ()
    
    var buttonClicked : ButtonClicked!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addTarget(self, action: #selector(pickCamera), for: .touchUpInside)
        imageView.backgroundColor = UIColor.darkGray
        
        imageView.setImage(#imageLiteral(resourceName: "picker_camera").withRenderingMode(.alwaysOriginal), for: .normal)
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        
        contentView.addSubview(imageView)
        imageView.edges(to: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pickCamera() {
        buttonClicked()
    }
}
