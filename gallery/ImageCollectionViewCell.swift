//
//  ImageCollectionViewCell.swift
//  gallery
//
//  Created by Peter Moon on 12/04/2018.
//  Copyright © 2018 Peter. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var indexPath:IndexPath?
    
}
