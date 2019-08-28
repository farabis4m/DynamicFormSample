//
//  DCheckBoxCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/19/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

enum SelectionMode: String {
    case checked = "switchOn"
    case uncheck = "switchOff"
}


class DCheckBoxCell: DBaseCell {
    
    var mode: SelectionMode = .uncheck

    @IBOutlet weak var buttonCheckBox: UIButton?
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        
    }
    
    override func update() {
        super.update()
        
        if let row = row as? DCheckBoxRow {
            titleLabel?.text = row.title
            buttonCheckBox?.setImage(UIImage(named: mode.rawValue), for: .normal)
        }
        titleLabel?.accessibilityIdentifier = "labelHeader"
    }
    
    @IBAction func buttonCheckBox(_ sender: UIButton) {
        mode = mode == .uncheck ? .checked : .uncheck
        guard let currentRow = row as? DCheckBoxRow else { return }
        currentRow.value = mode.rawValue
        sender.setImage(UIImage(named: mode.rawValue), for: .normal)
        currentRow.tapAction?()
        
    }
}

final class DCheckBoxRow: DBaseRow, RowType {
    

    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DCheckBoxCell.identifier)
        
        self.onRowValidationChanged { [weak self]  _ , _ in
            self?.validateRowError()
        }
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.placeholder = (param["hint"] as? String) ?? ""
        self.title = (param["title"] as? String) ?? ""
        if let validation = param["validations"] as? [[String: Any]] {
            self.addValidation(params: validation)
        }
        if let arrayValues = (param["values"]) as? [[String:String]] {
            createListableValues(arrayValues: arrayValues)
        }
    
    }
}
