//
//  ZPPageView.swift
//  ZPPageView
//
//  Created by apple on 2021/4/1.
//  Copyright © 2021 zhangpeng. All rights reserved.
//

import UIKit

class ZPPageView: UIView {

    // MARK: 定义属性
    fileprivate var titles : [String]!
    fileprivate var style : ZPPageStyle!
    fileprivate var childVcs : [UIViewController]!
    fileprivate weak var parentVc : UIViewController!
    
    fileprivate var titleView : ZPTitleView!
    fileprivate var contentView : ZPContentView!
    
    // MARK: 自定义构造函数
    init(frame: CGRect, titles : [String], style : ZPPageStyle, childVcs : [UIViewController], parentVc : UIViewController) {
        super.init(frame: frame)
        
        assert(titles.count == childVcs.count, "标题&控制器个数不同,请检测!!!")
        self.style = style
        self.titles = titles
        self.childVcs = childVcs
        self.parentVc = parentVc
        parentVc.automaticallyAdjustsScrollViewInsets = false
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK:- 设置界面内容
extension ZPPageView {
    fileprivate func setupUI() {
        let titleH : CGFloat = 44
        let titleFrame = CGRect(x: 0, y: 0, width: frame.width, height: titleH)
        titleView = ZPTitleView(frame: titleFrame, titles: titles, style : style)
        titleView.delegate = self
        addSubview(titleView)
        
        let contentFrame = CGRect(x: 0, y: titleH, width: frame.width, height: frame.height - titleH)
        contentView = ZPContentView(frame: contentFrame, childVcs: childVcs, parentViewController: parentVc)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.delegate = self
        addSubview(contentView)
    }
    
}


// MARK:- 设置ZPContentView的代理

extension ZPPageView : ZPContentViewDelegate {
    
    func contentView(_ contentView: ZPContentView, progress: CGFloat, sourceIndex: Int, targetIndex: Int) {
        titleView.setTitleWithProgress(progress, sourceIndex: sourceIndex, targetIndex: targetIndex)
    }
    
    func contentViewEndScroll(_ contentView: ZPContentView) {
        titleView.contentViewDidEndScroll()
    }
    
    
}


// MARK:- 设置ZPTitleView的代理
extension ZPPageView : ZPTitleViewDelegate {
    func titleView(_ titleView: ZPTitleView, selectedIndex index: Int) {
        contentView.setCurrentIndex(index)
    }
}
