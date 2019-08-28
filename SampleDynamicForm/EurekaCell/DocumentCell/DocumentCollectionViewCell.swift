//
//  DocumentCollectionViewCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 7/6/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit

class DocumentCollectionViewCell: UICollectionViewCell {
    
    static var cellIdentifier = "DocumentViewCell"
    
    var image: UIImage? {
        didSet {
            configureView()
        }
    }
    
    @IBOutlet weak var cellView: UIView?
    @IBOutlet weak var previewImageView: UIImageView?
    @IBOutlet weak var actionImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        previewImageView?.image = nil
        actionImageView?.image = UIImage(named: "add")
        cellView?.layer.borderColor = UIColor.lightGray.cgColor
        cellView?.layer.borderWidth = 1.0
        cellView?.layer.cornerRadius = 5
    }
    
    func configureView() {
        previewImageView?.image = image
        actionImageView?.image = UIImage(named: "cancel")
    }

}
