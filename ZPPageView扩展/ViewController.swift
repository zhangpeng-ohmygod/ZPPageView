//
//  ViewController.swift
//  ZPPageView扩展
//
//  Created by apple on 2021/4/7.
//

import UIKit
private let kEmoticonCell = "kEmoticonCell"

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageFrame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 300)
        
        let titles = ["土豪", "热门", "专属", "常见"]
        let style = ZPPageStyle()
        style.isShowBottomLine = true
        
        let layout = ZPPageCollectionViewLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.cols = 4
        layout.rows = 2
        
        let pageCollectionView = ZPPageCollectionView(frame: pageFrame, titles: titles, style: style, isTitleInTop: false, layout: layout)
        
        pageCollectionView.dataSource = self
        pageCollectionView.register(cell: UICollectionViewCell.self, identifier: kEmoticonCell)
        
        view.addSubview(pageCollectionView)
    }

}


extension ViewController : ZPPageCollectionViewDataSource {
    func numberOfSections(in pageCollectionView: ZPPageCollectionView) -> Int {
        return 4
    }
    
    func pageCollectionView(_ collectionView: ZPPageCollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 20
        } else if (section == 1) {
            return 14
        }else if (section == 2) {
            return 25
        }else  {
            return 30
        }
    }
    
    func pageCollectionView(_ pageCollectionView: ZPPageCollectionView, _ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEmoticonCell, for: indexPath)
        
        cell.backgroundColor = UIColor.randomColor()
        
        return cell
    }
}

