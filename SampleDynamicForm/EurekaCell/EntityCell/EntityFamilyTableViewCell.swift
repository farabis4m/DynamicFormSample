//
//  EntityFamilyTableViewCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 9/1/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit

class EntityFamilyTableViewCell: EntityTableViewCell {

    @IBOutlet weak var labelFamily: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func configureCell() {
        super.configureCell()
        guard let family = entity as? Family else { return }
        labelFamily?.text = family.family
    }
    
}
