//
//  DLabelCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/16/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit
import Eureka

final class DLabelCell: DBaseCell {
    
    @IBOutlet var labelHeader: UILabel?
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    override func update() {
        super.update()
        
        if let row = row as? DLabelRow, let attributedTitle = row.attributedTitle {
            labelHeader?.attributedText = attributedTitle
        } else {
            labelHeader?.text = row?.title
        }
        labelHeader?.accessibilityIdentifier = "labelHeader"
    }
}

final class DLabelRow: DBaseRow, RowType {
    
    var attributedTitle: NSAttributedString? {
        didSet{
            self.updateCell()
        }
    }
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<DBaseCell>(nibName: DLabelCell.identifier)
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.title = (param["title"] as? String) ?? ""
        if let validation = param["validations"] as? [[String: Any]] {
            self.addValidation(params: validation)
        }
    }
    
    convenience init(row: DynamicLabelRow) {
        self.init(tag: row.tag)
        tag   = row.tag
        title = row.title
        
    }
}

