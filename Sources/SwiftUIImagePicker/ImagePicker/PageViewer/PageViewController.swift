//
//  PageViewController.swift
//  BookKeeping
//
//  Created by 杨志远 on 2020/3/8.
//  Copyright © 2020 A.N.D. All rights reserved.
//

import SwiftUI
import UIKit

struct PageViewController: UIViewControllerRepresentable {
    
    var controllers : [UIViewController]
    
    @Binding var currentPage : Int
    @Binding var progress : CGFloat
    
    func makeCoordinator() -> PageViewController.Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PageViewController>) -> UIPageViewController {
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        let coordinator = context.coordinator
        page.dataSource = coordinator
        page.delegate = coordinator
        
        for view in page.view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.delegate = context.coordinator
            }
        }
        return page
    }
    
    func updateUIViewController(_ uiViewController: UIPageViewController, context: UIViewControllerRepresentableContext<PageViewController>) {
        /// When scorllDidScroll
        /// `updateUIViewController` will call multi times so too `setViewControllers`
        /// view will flash and produce bug
        /// to prevent call many times for the same currentPage
        let coor = context.coordinator
        if coor.last == currentPage {
            return
        }
        uiViewController.setViewControllers([controllers[currentPage]], direction: .forward, animated: false)
        coor.last = currentPage
    }
    
    class Coordinator: NSObject,UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate {
        var parent : PageViewController
        
        var last : Int = NSNotFound
        
        init(_ pageViewController : PageViewController) {
            self.parent = pageViewController
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard  let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index == 0 {
                return nil
            }
            return parent.controllers[index - 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            if index + 1 == parent.controllers.count {
                return nil
            }
            
            return parent.controllers[index + 1]
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed,
                let visibleViewController = pageViewController.viewControllers?.first,
                let index = parent.controllers.firstIndex(of: visibleViewController)
            {
                parent.currentPage = index
            }
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let width = scrollView.frame.size.width
            let offsetX = scrollView.contentOffset.x
            let progress = (offsetX - width) / width
            parent.progress = progress
        }

    }
}
