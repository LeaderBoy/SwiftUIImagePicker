//
//  PageItem.swift
//  BookKeeping
//
//  Created by 杨志远 on 2020/3/9.
//  Copyright © 2020 A.N.D. All rights reserved.
//

import UIKit

/// Bar Item
public struct PageBarItem {
    public var title : String?
    public var image : UIImage?
    
    public var titleColor : UIColor = .gray
    public var titleSelectedColor : UIColor = .black
    /// Title font
    public var titleFont : UIFont = .systemFont(ofSize: 15)
    /// Title Font on selected
    public var titleSelectedFont : UIFont = .systemFont(ofSize: 17)
    /// Enable fade font animation
    /// default is true
    public var enableFadeFont = true
    /// Enable fade color animation
    /// default is true
    public var enableFadeColor = true
    
    public init(title :String?,image : String? = nil,titleColor : UIColor = .gray,titleSelectedColor : UIColor = .black,titleFont : UIFont = .systemFont(ofSize: 15),titleSelectedFont : UIFont = .systemFont(ofSize: 17),enableFadeFont : Bool = true,enableFadeColor : Bool = true) {
        self.title = title
        self.titleColor = titleColor
        self.titleSelectedColor = titleSelectedColor
        self.titleFont = titleFont
        self.titleSelectedFont = titleSelectedFont
        self.enableFadeFont = enableFadeFont
        self.enableFadeColor = enableFadeColor
    }
    
    public var width : CGFloat {
        if let title = title {
            let maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 14.0)
            let options = NSStringDrawingOptions.init(rawValue: NSStringDrawingOptions.usesLineFragmentOrigin.rawValue | NSStringDrawingOptions.usesFontLeading.rawValue)
            let attributes = [NSAttributedString.Key.font:titleSelectedFont]
            let size = NSString(string: title).boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
            return ceil(size.width)
        }
        return 0
    }
}
