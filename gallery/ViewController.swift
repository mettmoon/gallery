//
//  ViewController.swift
//  gallery
//
//  Created by Peter Moon on 11/04/2018.
//  Copyright © 2018 Peter. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    var items:[GettyItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        GettyManager().loadGetty { (items) in
            guard let items = items else {
                NSLog("데이터를 불러오지못함")
                return
            }
            DispatchQueue.main.async {
                self.items = items
                self.collectionView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateCollectionViewLayout()

    }
    func updateCollectionViewLayout(){
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var width:CGFloat = 100
        let remainder = self.collectionView.frame.width.truncatingRemainder(dividingBy: width)
        let numberOfRows = (self.collectionView.frame.width - remainder) / width
        width += remainder / numberOfRows
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        collectionView.collectionViewLayout = layout

    }


}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Image Cell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = nil
        cell.indexPath = indexPath
        let data = self.item(for: indexPath)
        cell.titleLabel.text = data.title
        if let image = data.imageURL.cachedImage() {
            cell.imageView.image = image
            cell.indicatorView.isHidden = true
        }else{
            cell.indicatorView.isHidden = false
            cell.indicatorView.alpha = 1
            cell.indicatorView.startAnimating()
            data.imageURL.downloadImage { (image, error) in
                if let error = error {
                    cell.indicatorView.stopAnimating()
                    NSLog(error.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    //재사용고려
                    if cell.indexPath == indexPath {
                        cell.imageView.image = image
                        cell.imageView.alpha = 0
                        UIView.animate(withDuration: 0.35, animations: {
                            cell.imageView.alpha = 1
                            cell.indicatorView.alpha = 0
                            
                        }, completion: { (finish) in
                            cell.indicatorView.stopAnimating()
                            cell.indicatorView.isHidden = true
                        })
                    }
                    
                }
            }
        }
        return cell
    }
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let data = self.item(for: indexPath)
//        let cell = cell as! ImageCollectionViewCell
//        if let image = data.imageURL.cachedImage() {
//            cell.imageView.image = image
//        }
//
//    }
    func item(for indexPath:IndexPath) -> GettyItem {
        return self.items[indexPath.row]
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.item(for: indexPath)
        UIApplication.shared.open(item.pageURL, options: [:], completionHandler: nil)
    }
}

extension ViewController : UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let data = self.item(for: indexPath)
            data.imageURL.downloadImage(nil)
        }
    }
}
