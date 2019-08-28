//
//  BasePickerRow.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/20/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class BasePickerViewCell: BasicFieldTableViewCell<String>, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var currentRow:BasePickerRow? {
        let basicPickerRow =  self.row as? BasePickerRow
        return basicPickerRow
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currentRow?.values.count ?? 0;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let value =  currentRow?.values[row]
        if textField?.text?.isEmpty ?? false , let valueFirst = value {
            currentRow?.value = valueFirst.desc
            currentRow?.updateCell()
        }
        
        return value?.desc ?? ""
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let value =  currentRow?.values[row]
        currentRow?.value = value?.desc
        currentRow?.updateCell()
    }
    
    
    private var pickerView: UIPickerView?
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        pickerView = UIPickerView()
        pickerView?.dataSource = self
        pickerView?.delegate = self
        textField?.inputView = pickerView
        
        // picker toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(buttonActionDone))
        
        // if you remove the space element, the "done" button will be left aligned
        // you can add more items if you want
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textField?.inputAccessoryView = toolBar
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? DPickerRow else { return }
        textField?.keyboardType = row.keyboardType
        
        textField?.accessibilityIdentifier = "textField"
        titleLabel?.accessibilityIdentifier = "labelTitle"
        titleLabel?.text = row.title
        textField?.text = row.value
        textField?.placeholder = row.placeholder
        configureView()
    }
    
    private func configureView() {
        textField?.layer.borderWidth = 1.5
        textField?.layer.cornerRadius = 4.0
    }
    
    
    @objc func buttonActionDone() {
        endEditing(true)
        row.value = textField?.text ?? ""
        if let option = (row as? BasePickerRow)?.selectedOption(description: row.value ?? "") {
            (row as? BasePickerRow)?.callbackOnRowFocusChanged?(option)
        }
    }
    
}


class BasePickerRow: BaseFieldRow<BasePickerViewCell> {
    
    var values:[DynamicRow.Option] = [DynamicRow.Option]()
//    var placeholder: String?
//    
//    var titleText: String?
//    var keyboardType = UIKeyboardType.default
    
    var callbackOnRowFocusChanged: ((DynamicRow.Option) -> Void)?
    
    required init(tag: String?) {
        super.init(tag: tag)
    }
    
    func selectedOption(description: String) -> DynamicRow.Option? {
        return values.filter{ $0.desc == description }.first
    }
    
    func createListableValues(arrayValues:[[String:String]]) {
        arrayValues.forEach { [weak self] (value) in
            var dLov = DynamicRow.Option()
            dLov.code = (value["code"]) ?? ""
            dLov.desc = (value["desc"]) ?? ""
            self?.values.append(dLov)
        }
    }
    
    func addValidation(params: [[String: Any]]) {
        params.forEach { (dict) in
            if (dict["rule"] as? String) == Rule.required.rawValue {
                add(rule: RuleRequired(msg: (dict[Rule.required.message] as? String) ?? "", id: nil))
            }
            else if (dict["rule"] as? String) == Rule.regex.rawValue {
                add(rule: RuleRegExp(regExpr: (dict[Rule.regex.value] as? String) ?? "", allowsEmpty: true, msg: (dict[Rule.regex.message] as? String) ?? "", id: nil))
            }
        }
    }
    
}

