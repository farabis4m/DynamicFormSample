//
//  DDatePickerCell.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/17/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

final class DDatePickerRow: DBaseRow, RowType {
    override var placeholder: String? {
        didSet {
            let cell = self.cell as? DTextFieldCell
            cell?.textField?.placeholder = placeholder
        }
    }
    
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DDatePickerCell.identifier)
        
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

class DDatePickerCell: DBaseCell {
    
    var currentRow:DDatePickerRow? {
        let basicPickerRow =  self.row as? DDatePickerRow
        return basicPickerRow
    }
    
    private var pickerView: UIDatePicker?
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        pickerView = UIDatePicker()
        pickerView?.datePickerMode = .date
        textField?.inputView = pickerView
        pickerView?.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? DDatePickerRow else { return }
        textField?.keyboardType = row.keyboardType
        textField?.isUserInteractionEnabled = row.isEditable
        
        textField?.accessibilityIdentifier = "textField"
        titleLabel?.accessibilityIdentifier = "labelTitle"
        titleLabel?.text = row.title
        textField?.text = row.value ?? ""
        configureView()
    }
    
    @objc func dateChanged() {
        //For date format
        guard let formatter = (self.row as? DBaseRow)?.formatter as? DateFormatter else { return}
        currentRow?.value = formatter.string(from: pickerView?.date ?? Date())
        currentRow?.updateCell()
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
        (row as? DDatePickerRow)?.callbackOnRowFocusChanged?()
    }
    
}

