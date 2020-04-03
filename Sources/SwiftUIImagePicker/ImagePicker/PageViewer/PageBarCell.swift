//
//  PageBarCell.swift
//  ImagePicker
//
//  Created by 杨 on 2020/4/2.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

struct PageBarCellConfigutation {
    let index : Int
    var numberOfPages : Int
    var currentPage : Int
    var progress : CGFloat
}

class PageBarCell: UICollectionViewCell {
    
    static let reusedID = "PageBarCell"
    
    var item : PageBarItem! {
        didSet {
            if let image = item.image {
                imageView.isHidden = false
                imageView.image = image
            } else {
                imageView.isHidden = true
            }
            
            if let title = item.title {
                label.text = title
                label.isHidden = false
            } else {
                label.isHidden = true
            }
        }
    }
    
    fileprivate let label = UILabel()
    fileprivate let imageView = UIImageView()
    fileprivate let stackView = UIStackView()
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.font = item.titleSelectedFont
                label.textColor = item.titleSelectedColor
            } else {
                label.font = item.titleFont
                label.textColor = item.titleColor
            }
        }
    }
    
    var configuration : PageBarCellConfigutation! {
        didSet {
            label.font = fadeFont(at: configuration.index)
            label.textColor = fadeColor(at: configuration.index)
        }
    }
    
    func fadeFont(at index : Int) -> UIFont {
        let enableFadeFont      = item.enableFadeFont
        let currentPage         = configuration.currentPage
        let selectedFontSize    = item.titleSelectedFont.pointSize
        let numberOfPages       = configuration.numberOfPages
        let progress            = configuration.progress
        let normalFontSize      = item.titleFont.pointSize
        
        if !enableFadeFont {
            if currentPage == index {
                return item.titleSelectedFont
            } else {
                return item.titleFont
            }
        }
        
        if currentPage == index {
            if (currentPage == 0 && progress <= 0) || (currentPage == numberOfPages - 1 && progress >= 0) {
                return item.titleSelectedFont
            }
            let currentSize = selectedFontSize - (selectedFontSize - normalFontSize) * abs(progress)
            return .systemFont(ofSize: currentSize)
        } else if (index == currentPage + 1) && progress >= 0 {
            let currentSize = normalFontSize + (selectedFontSize - normalFontSize) * progress
            return .systemFont(ofSize: currentSize)
        } else if (index == currentPage - 1) && progress < 0 {
            let currentSize = normalFontSize - (selectedFontSize - normalFontSize) * progress
            return .systemFont(ofSize: currentSize)
        }
        return item.titleFont
    }
    
    func fadeColor(at index : Int) -> UIColor {
        let enableFadeColor = item.enableFadeColor
        let currentPage = configuration.currentPage
        let selectedColor = item.titleSelectedColor
        let numberOfPages = configuration.numberOfPages
        let progress = configuration.progress
        let normalColor = item.titleColor
        
        if !enableFadeColor {
            if currentPage == index {
                return selectedColor
            } else {
                return normalColor
            }
        }
        
        if currentPage == index {
            if (currentPage == 0 && progress <= 0) || (currentPage == numberOfPages - 1 && progress >= 0) {
                return selectedColor
            }
            return selectedColor.toUIColor(normalColor, percentage: abs(progress))
        } else if ((index == currentPage + 1) && progress >= 0) || ((index == currentPage - 1) && progress < 0) {
            return normalColor.toUIColor(selectedColor, percentage: abs(progress))
        }
        return normalColor
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.alignment = .fill
        stackView.axis = .vertical
        
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(imageView)
        
        label.textAlignment = .center
        imageView.contentMode = .scaleAspectFit
        
        addSubview(stackView)
        stackView.edges(to: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIColor {
    func toUIColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 1), 0)
        switch percentage {
        case 0: return self
        case 1: return color
        default:
            var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
            guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1) else { return self }
            guard color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else { return self }
            let uiColor = UIColor(red: CGFloat(r1 + (r2 - r1) * percentage),
            green: CGFloat(g1 + (g2 - g1) * percentage),
            blue: CGFloat(b1 + (b2 - b1) * percentage),
            alpha: CGFloat(a1 + (a2 - a1) * percentage))
            return uiColor
        }
    }
}
