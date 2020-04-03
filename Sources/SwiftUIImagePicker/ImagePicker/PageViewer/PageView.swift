//
//  PageView.swift
//  BookKeeping
//
//  Created by 杨志远 on 2020/3/8.
//  Copyright © 2020 A.N.D. All rights reserved.
//

import SwiftUI

public struct PageView<Page : View>: View {
    
    public var viewControllers : [UIHostingController<Page>]
    
    @Binding public var currentPage : Int
    @Binding public var progress : CGFloat
        
    public init(currentPage : Binding<Int>,progress :Binding<CGFloat>, views : [Page]) {
        self._currentPage = currentPage
        self._progress = progress
        self.viewControllers = views.map{
            let root = UIHostingController(rootView: $0)
            root.view.backgroundColor = UIColor.clear
            return root
        }
    }
    
    public var body: some View {
        VStack {
            PageViewController(controllers: viewControllers, currentPage: $currentPage, progress: $progress)
        }
    }
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        PageView(currentPage: .constant(0), progress: .constant(0), views: [Color.red,Color.yellow])
    }
}
