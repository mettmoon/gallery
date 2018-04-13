//
//  DetailViewController.swift
//  gallery
//
//  Created by Peter Moon on 13/04/2018.
//  Copyright © 2018 Peter. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var referTextLabel: UILabel!
    @IBOutlet weak var detailTextLabel: UILabel!
    @IBOutlet weak var infoTextLabel: UILabel!
    var item:GettyItem?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadDataFromCache()
        self.loadData()
    }
    func loadDataFromCache(){
        self.titleLabel.text = item?.title
        self.imageView.image = item?.imageURL.cachedImage()
        self.referTextLabel.text = item?.referText
        self.detailTextLabel.text = item?.detailText
        self.infoTextLabel.text = item?.infoText
        item?.detailImageURL?.downloadImage({ (image, error) in
            DispatchQueue.main.async {
                if let image = image {
                    if let lc = self.imageView.constraints.filter({ (lc) -> Bool in
                        lc.identifier == "Ratio"
                    }).first {
                        self.imageView.removeConstraint(lc)
                    }
                    let lc = NSLayoutConstraint(item: self.imageView, attribute: .width, relatedBy: .equal, toItem: self.imageView, attribute: .height, multiplier: image.size.width / image.size.height, constant: 0)
                    lc.identifier = "Ratio"
                    lc.priority = UILayoutPriority(200)
                    self.imageView.addConstraint(lc)
                    self.imageView.image = image
                    self.view.layoutIfNeeded()
                }
            }
        })
    }
    func loadData(){
        self.item?.loadDetailData {
            DispatchQueue.main.async {
                self.loadDataFromCache()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
