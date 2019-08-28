//
//  DSwitchCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/17/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

final class DSwitchCell: DBaseCell {
    
    @IBOutlet weak var switchRow: UISwitch?
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        switchRow?.setOn(false, animated: false)
    }
    
    override func update() {
        super.update()
        
        if let row = row as? DSwitchRow, let attributedTitle = row.attributedTitle {
            titleLabel?.attributedText = attributedTitle
        } else {
            titleLabel?.text = row?.title
        }
        titleLabel?.accessibilityIdentifier = "labelHeader"
    }
}

final class DSwitchRow: DBaseRow {
    
    var attributedTitle: NSAttributedString? {
        didSet{
            self.updateCell()
        }
    }
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DSwitchCell.identifier)
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.title = (param["title"] as? String) ?? ""
        if let validation = param["validations"] as? [[String: Any]] {
            self.addValidation(params: validation)
        }
    }
}
