//
//  ValidationCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/13/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class ValidationCell: DBaseCell {
    
    @IBOutlet var labelValidation: UILabel?
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func update() {
        super.update()
        
        if let row = row as? ValidationRow, let attributedTitle = row.attributedTitle {
            labelValidation?.attributedText = attributedTitle
        } else {
            labelValidation?.text = row?.title
        }
        labelValidation?.accessibilityIdentifier = "labelValidation"
    }
}

final class ValidationRow: DBaseRow, RowType {
    
    var attributedTitle: NSAttributedString? {
        didSet{
            self.updateCell()
        }
    }
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<DBaseCell>(nibName: ValidationCell.identifier)
    }
}
