//
//  BaseImageCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/20/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class BaseImageViewCell: Cell<UIImage>, CellType {
    
    var currentRow: BaseImageRow? {
       return row as? BaseImageRow
    }
    
    @IBOutlet weak var titleLabel: UILabel?
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func update() {
        super.update()
        guard let currentRow = row as? BaseImageRow else { return }
        titleLabel?.text = currentRow.title
        textLabel?.text = nil
        
    }
}


class BaseImageRow: Row<BaseImageViewCell> {
    
    var callbackOnRowFocusChanged: (() -> Void)?

    required init(tag: String?) {
        super.init(tag: tag)
    }
}
