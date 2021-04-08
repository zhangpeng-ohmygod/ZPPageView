//
//  ZPPageCollectionView.swift
//  ZPPageView扩展
//
//  Created by apple on 2021/4/7.
//

import UIKit


protocol ZPPageCollectionViewDataSource : class {
    func numberOfSections(in pageCollectionView : ZPPageCollectionView) -> Int
    func pageCollectionView(_ collectionView: ZPPageCollectionView, numberOfItemsInSection section: Int) -> Int
    func pageCollectionView(_ pageCollectionView : ZPPageCollectionView ,_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
}


class ZPPageCollectionView: UIView {
    
    weak var dataSource : ZPPageCollectionViewDataSource?
    
    fileprivate var titles : [String]
    fileprivate var isTitleInTop : Bool
    fileprivate var style : ZPPageStyle
    fileprivate var layout : ZPPageCollectionViewLayout
    fileprivate var collectionView : UICollectionView!
    fileprivate var pageControl : UIPageControl!
    fileprivate var titleView : ZPTitleView!
    fileprivate var sourceIndexPath : IndexPath = IndexPath(item: 0, section: 0)
    
    init(frame: CGRect, titles : [String], style : ZPPageStyle, isTitleInTop : Bool, layout : ZPPageCollectionViewLayout) {
        self.titles = titles
        self.style = style
        self.isTitleInTop = isTitleInTop
        self.layout = layout
        
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



// MARK:- 设置UI界面
extension ZPPageCollectionView {
    fileprivate func setupUI() {
        // 1.创建titleView
       
        let titleY = isTitleInTop ? 0 : bounds.height - style.titleHeight
        let titleFrame = CGRect(x: 0, y: titleY, width: bounds.width, height: style.titleHeight)
        titleView = ZPTitleView(frame: titleFrame, titles: titles, style: style)
        addSubview(titleView)
       
        titleView.delegate = self
        titleView.backgroundColor = UIColor.randomColor()
        
        // 2.创建UIPageControl
        let pageControlHeight : CGFloat = 20
        let pageControlY = isTitleInTop ? (bounds.height - pageControlHeight) : (bounds.height - pageControlHeight - style.titleHeight)
        let pageControlFrame = CGRect(x: 0, y: pageControlY, width: bounds.width, height: pageControlHeight)
        pageControl = UIPageControl(frame: pageControlFrame)
        pageControl.numberOfPages = 4
        pageControl.isEnabled = false
        addSubview(pageControl)
        pageControl.backgroundColor = UIColor.randomColor()
        
        // 3.创建UICollectionView
        let collectionViewY = isTitleInTop ? style.titleHeight : 0
        let collectionViewFrame = CGRect(x: 0, y: collectionViewY, width: bounds.width, height: bounds.height - style.titleHeight - pageControlHeight)
        collectionView = UICollectionView(frame: collectionViewFrame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        collectionView.backgroundColor = UIColor.randomColor()
    }
}


// MARK:- 对外暴露的方法
extension ZPPageCollectionView {
    func register(cell : AnyClass?, identifier : String) {
        collectionView.register(cell, forCellWithReuseIdentifier: identifier)
    }
    
    func register(nib : UINib, identifier : String) {
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
}


// MARK:- UICollectionViewDataSource
extension ZPPageCollectionView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let itemCount = dataSource?.pageCollectionView(self, numberOfItemsInSection: section) ?? 0
        
        if section == 0 {
            pageControl.numberOfPages = (itemCount - 1) / (layout.cols * layout.rows) + 1
        }
        
        return itemCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return dataSource!.pageCollectionView(self, collectionView, cellForItemAt: indexPath)
    }
}


// MARK:- UICollectionViewDelegate
extension ZPPageCollectionView : UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewEndScroll()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollViewEndScroll()
        }
    }
    
    fileprivate func scrollViewEndScroll() {
        // 1.取出在屏幕中显示的Cell
        let point = CGPoint(x: layout.sectionInset.left + 1 + collectionView.contentOffset.x, y: layout.sectionInset.top + 1)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        
        // 2.判断分组是否有发生改变
        if sourceIndexPath.section != indexPath.section {
            // 3.1.修改pageControl的个数
            let itemCount = dataSource?.pageCollectionView(self, numberOfItemsInSection: indexPath.section) ?? 0
            pageControl.numberOfPages = (itemCount - 1) / (layout.cols * layout.rows) + 1
            
            // 3.2.设置titleView位置
            titleView.setTitleWithProgress(1.0, sourceIndex: sourceIndexPath.section, targetIndex: indexPath.section)
            
            // 3.3.记录最新indexPath
            sourceIndexPath = indexPath
        }
        
        // 3.根据indexPath设置pageControl
        pageControl.currentPage = indexPath.item / (layout.cols * layout.rows)
    }
}


// MARK:- ZPTitleViewDelegate
extension ZPPageCollectionView : ZPTitleViewDelegate {
    func titleView(_ titleView: ZPTitleView, selectedIndex index: Int) {
        let indexPath = IndexPath(item: 0, section: index)
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
       // collectionView.scrollToItem(at: <#T##IndexPath#>, at: <#T##UICollectionView.ScrollPosition#>, animated: <#T##Bool#>)
       // collectionView.contentOffset.x -= layout.sectionInset.left
        
        scrollViewEndScroll()
    }
}
