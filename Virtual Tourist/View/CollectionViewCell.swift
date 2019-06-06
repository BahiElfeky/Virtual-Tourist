//
//  CollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Bahi El Feky on 5/17/19.
//  Copyright © 2019 Bahi El Feky. All rights reserved.
//

import UIKit
import Kingfisher

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.image = nil
        cellImage.kf.indicatorType = .activity
    }
}
