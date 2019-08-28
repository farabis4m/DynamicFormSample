//
//  DTextFieldCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/12/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

final class DTextFieldRow: DBaseRow, RowType {
    
    override var placeholder: String? {
        didSet {
            let cell = self.cell as? DTextFieldCell
            cell?.textField?.placeholder = placeholder
        }
    }
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DTextFieldCell.identifier)
        
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
    }
    
    convenience init(row: DynamicTextFieldRow) {
        self.init(tag: row.tag)
//        placeholder = row.placeholder
        title = row.title
       
    }
}

class DTextFieldCell: DBaseCell {
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? DTextFieldRow else { return }
        textField?.keyboardType = row.keyboardType
        textField?.isUserInteractionEnabled = row.isEditable
        
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
    
    @objc func buttonActionDone() {
        row.value = textField?.text ?? ""
        (row as? DTextFieldRow)?.callbackOnRowFocusChanged?()
    }
    
}
