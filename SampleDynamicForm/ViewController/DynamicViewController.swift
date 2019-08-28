//
//  DynamicViewController.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/20/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit
import Eureka

class DynamicViewController: FormViewController {
    
    var dynamicForm: DynamicForm?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let path = Bundle.main.path(forResource: "leave", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonObjct = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else { return }
        initializeForm(jsonObjct)
    }

    
    func initializeForm(_ dict: [String: Any]) {
        dynamicForm = DynamicForm.decode(params: dict)
        print(dynamicForm)
        
        if let dynamicRows = dynamicForm?.data {
            let section = Section()
            form +++ section
            
            dynamicRows.forEach { [weak self] (dynamicRow) in
                if let row = dynamicRow.row {
                    section <<< row
                    
                    self?.handlePickerRow(row: row)
                }
            }
        }
    }

    func handlePickerRow(row: BaseRow) {
        guard let pickerRow = row as? BasePickerRow else { return }
        pickerRow.callbackOnRowFocusChanged = { [weak self] option in
            guard let welf = self else { return }
            guard welf.dynamicForm?.relations?.containsComponent(component: pickerRow.tag) ?? false else { return }
            guard let relation = welf.dynamicForm?.relations?.relationFor(component: pickerRow.tag) else { return }
            
            relation.values?.forEach({ (value) in
                if option.code == value.code {
                    
                }
            })
        }
    }
    

}

extension Array where Element: Relation {
    func containsComponent(component: String?) -> Bool {
        return contains{ $0.component == component }
    }
    
    func relationFor(component: String?) -> Relation? {
        return filter{ $0.component == component }.first
    }
}
