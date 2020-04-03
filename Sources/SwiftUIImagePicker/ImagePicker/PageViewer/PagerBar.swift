//
//  PagerBar.swift
//  ImagePicker
//
//  Created by 杨 on 2020/4/2.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit
import SwiftUI

public struct PagerBar : UIViewRepresentable {
    
    @Binding public var currentPage : Int
    @Binding public var progress : CGFloat
    
    public var items : [PageBarItem]
    
    public init(currentPage : Binding<Int>,progress : Binding<CGFloat>,items: [PageBarItem]) {
        self._currentPage = currentPage
        self._progress = progress
        self.items = items
    }
    
    public func makeCoordinator() -> PagerBar.Coordinator {
        return Coordinator()
    }
    
    public func makeUIView(context: Context) -> UIKitPagerBar {
        let view = UIKitPagerBar(currentPage: $currentPage,progress: $progress, items: items)
        return view
    }
    
    public func updateUIView(_ uiView: UIKitPagerBar, context: Context) {
        let last = context.coordinator.lastPage
        
        DispatchQueue.main.async {
            if last != self.currentPage {
                uiView.currentPage = self.currentPage
                context.coordinator.lastPage = self.currentPage
            }
            if !self.floatEqual(context.coordinator.lastProgress, self.progress) {
                uiView.progress = self.progress
                context.coordinator.lastProgress = self.progress
            }
        }
    }
    
    func floatEqual(_ a: CGFloat, _ b: CGFloat) -> Bool {
        let precised = 4
        return a.precised(precised) == b.precised(precised)
    }
    
    public class Coordinator: NSObject {
        var lastPage : Int = NSNotFound
        var lastProgress : CGFloat = 0
    }
}

/// CGFloat precised
/// a : CGFloat, b:CGFloat
/// a.precised(4) == b.precised(4)
/// https://stackoverflow.com/questions/43911229/comparing-two-identical-double-value-return-false-swift-3
extension CGFloat {
    func precised(_ value: Int = 1) -> CGFloat {
        let offset = pow(10, CGFloat(value))
        return (self * offset).rounded() / offset
    }

    static func equal(_ lhs: CGFloat, _ rhs: CGFloat, precise value: Int? = nil) -> Bool {
        guard let value = value else {
            return lhs == rhs
        }
        return lhs.precised(value) == rhs.precised(value)
    }
}


public class UIKitPagerBar: UIView {
    
    struct ItemFrame {
        let minX : CGFloat
        let maxX : CGFloat
        let midX : CGFloat
        let width : CGFloat
                
        func needOffset(width : CGFloat,contentSize : CGSize) -> CGFloat {
            let centerX = width / 2
            let contentWidth = contentSize.width
            /// 需要中心偏移的距离
            let centerOffset = midX - centerX
            if centerOffset <= 0 {
                return 0
            } else {
                if (centerOffset + width) > contentWidth {
                    return contentWidth - width
                }
                return centerOffset
            }
        }
    }
    
    @Binding var currentPage : Int {
        didSet {
            let width = collectionView.bounds.width
            let contentSize = collectionView.contentSize
            let currentItemFrame = itemFrames[currentPage]
            let centerOffset = currentItemFrame.needOffset(width: width, contentSize: contentSize)
            collectionView.setContentOffset(CGPoint(x: centerOffset, y: 0), animated: true)
            collectionView.reloadData()
        }
    }
    
    @Binding var progress : CGFloat {
        didSet {
            collectionView.reloadData()
        }
    }
    
    lazy var itemFrames : [ItemFrame] = {
        let spacing = itemSpacing
        let widths = items.map{$0.width}
        var frames : [ItemFrame] = []
        
        if widths.count == 1 {
            let w = widths.first!
            let frame = ItemFrame(minX: 0, maxX: w, midX: w / 2, width: w)
            return [frame]
        }
        
        var last : CGFloat = 0
        for (index,w) in widths.enumerated() {
            if index == widths.count - 1 {
                last += spacing
                let frame = ItemFrame(minX: last, maxX: last + w, midX: last + w / 2, width: w)
                frames.append(frame)
            } else if index == 0 {
                let frame = ItemFrame(minX: 0, maxX: w, midX: w / 2, width: w)
                frames.append(frame)
                last += w
            } else {
                last += spacing
                let frame = ItemFrame(minX: last, maxX: last + w, midX: last + w / 2, width: w)
                frames.append(frame)
                last += w
            }
        }
        return frames
    }()
    
    let items : [PageBarItem]
    var itemSpacing : CGFloat = 20
    
    private var collectionView : UICollectionView!
    
    init(currentPage: Binding<Int>,progress: Binding<CGFloat>,items : [PageBarItem]) {
        self.items = items
        self._currentPage = currentPage
        self._progress = progress
        super.init(frame: .zero)
        layoutCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = itemSpacing
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        addSubview(collectionView)
        collectionView.edges(to: self)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.register(PageBarCell.self, forCellWithReuseIdentifier: PageBarCell.reusedID)
        
        let indexPath = IndexPath(row: currentPage, section: 0)
        DispatchQueue.main.async {
            self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
        }
    }
}

extension UIKitPagerBar : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.row]
        return CGSize(width: item.width, height: self.collectionView.bounds.height)
    }
}

extension UIKitPagerBar : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentPage = indexPath.row
    }
}

extension UIKitPagerBar : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageBarCell.reusedID, for: indexPath) as! PageBarCell
        cell.item = items[indexPath.row]
        cell.configuration = PageBarCellConfigutation(index: indexPath.row, numberOfPages: items.count, currentPage: currentPage, progress: progress)
        return cell
    }
}


extension UICollectionView {
    func scrollToLast(animated : Bool = true) {
        guard numberOfSections > 0 else {
            return
        }
        let lastSection = numberOfSections - 1

        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }

        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: animated)
    }
}

extension UIView {
    @discardableResult
    func edges(to view : UIView,insets : UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
       let layouts = [
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: insets.left),
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: insets.right),
        self.topAnchor.constraint(equalTo: view.topAnchor,constant: insets.top),
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: insets.bottom),
        ]
        
        NSLayoutConstraint.activate(layouts)
        
        return layouts
    }
}
