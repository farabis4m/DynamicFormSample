//
//  DPickerCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/13/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

final class DPickerRow: BasePickerRow, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<BasePickerViewCell>(nibName: DPickerCell.identifier)
        
        self.onRowValidationChanged { [weak self]  _ , _ in
            self?.validateRowError()
        }
    }
    
    convenience init(row: DynamicDropDownRow) {
        self.init(tag: row.tag)
        placeholder = row.placeholder
        values      = row.options
        title       = row.title
        tag         = row.tag
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

class DPickerCell: BasePickerViewCell {
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? DPickerRow else { return }
        
        textField?.accessibilityIdentifier = "textField"
        titleLabel?.accessibilityIdentifier = "labelTitle"
        titleLabel?.text = row.title
        configureView()
    }
    
    private func configureView() {
        textField?.layer.borderWidth = 1.5
        textField?.layer.cornerRadius = 4.0
    }
    
    @objc func buttonActionSecureEntry(sender: UIButton) {
        
        sender.isSelected.toggle()
        textField?.isSecureTextEntry = !sender.isSelected
        (row as? DBaseRow)?.isSecureEntry = !sender.isSelected
    }
    
//    @objc override func buttonActionDone() {
//        row.value = textField?.text ?? ""
//        (row as? DPickerRow)?.callbackOnRowFocusChanged?()
//    }
    
}
