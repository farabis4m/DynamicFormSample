//
//  ViewController.swift
//  SampleDynamicForm
//
//  Created by Jafar Khan on 6/11/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit
import Eureka

class DynamicFormViewController: BaseDynamicFormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let path = Bundle.main.path(forResource: "dynamicForm", ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe), let jsonObjct = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return }
        
        initializeForm(dict: jsonObjct)
    }
    
  override func getFormRowByType(params: [String: Any]) -> BaseRow? {
        let controlType = params["type"] as? String ?? ""
        
        //Creating the control by controlType
    
//        DynamicRow.RowType(rawValue: controlType)
        guard let control = DFormComponent.init(rawValue: controlType) else { return nil }
        var row: BaseRow?
        switch control {
        case .controlEditText:
            row =  DTextFieldRow(param: params)
            (row as? DBaseRow)?.callbackOnRowFocusChanged = {
                print("callBack")
            }
        case .controlSearchText:
            row =  DSearchRow(param: params)
        case .controlLabelRow:
            row =  DLabelRow(param: params)
        case .controlDatePickerRow:
            row =  DDatePickerRow(param: params)
        case .controlSwitchRow:
            row =  DSwitchRow(param: params)
        case .controlPicker:
            row =  DPickerRow(param: params)
        case .controlCheckBox:
            row =  DCheckBoxRow(param: params)
        case .controlButton:
            row =  DButtonRow(param: params)
            (row as? DBaseRow)?.callbackOnRowFocusChanged = {
                print("callBacks")
                self.printAllValues()
            }
        case .controlImage:
            row = DImagePickerRow(param: params)
            (row as? DImagePickerRow)?.callbackOnRowFocusChanged = {
            }
        case .controlDocument:
            row = DDocumentRow(param: params)
        }
        return row
        
    }
    
    func printAllValues() {
        for row in form.allRows {
            let value = form.value(for: row.tag ?? "") ?? "Empty"
            print("Row: \(row.title) value: \(value) base value: \(row.baseValue)")
            
        }
    }
}

extension Form {
    // get value of form from tag without typecasting
    func value<T>(for tag: String) -> T? {
        return values()[tag] as? T
    }
}
