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
        
        manageServices()

    }
    
    func handlePickerRow(row: BaseRow) {
        guard let pickerRow = row as? BasePickerRow else { return }
        pickerRow.callbackOnRowFocusChanged = { [weak self] option in
            guard let welf = self else { return }
            welf.manageRelationFor(picker: pickerRow, selectedOption: option)
        }
    }
    
    func manageRelationFor(picker: BasePickerRow, selectedOption: DynamicDropDownRow.Option) {
        guard let relation = dynamicForm?.relations?.relationFor(component: picker.tag) else { return }
        
        // unhide rows in related list
        form.toggleRowsWith(tags: relation.relatedList, shouldHide: false)
        
        // check if selcted code is present in relations
        guard let value = relation.values?.valueFor(code: selectedOption.code ?? "") else { return }
        
        // get the components to hide
        guard  let relatedControls = value.relatedControls else { return }
        
        // set the component value
        let rowTags = relation.relatedList?.filter{ !relatedControls.components().contains($0) }
        
        // hide rows
        form.toggleRowsWith(tags: rowTags)
    }
    
    func manageServices() {
        dynamicForm?.services?.forEach({ (service) in
            guard let relatedRows =  form.rowsBy(tags: service.relatedComponents) else { return }
            
            relatedRows.forEach { (row) in
                
                if let dBaseRow = row as? DBaseRow {
                    dBaseRow.callbackOnRowFocusChanged = { [weak self] in
                        if relatedRows.areCompleted() {
                            self?.callServiceWith(url: service.endPoint)
                        }
                    }
                }
                else if let dBaseRow = row as? BasePickerRow {
                    dBaseRow.callbackOnRowFocusChanged = { [weak self] option in
                        self?.manageRelationFor(picker: dBaseRow, selectedOption: option)
                        if relatedRows.areCompleted() {
                            self?.callServiceWith(url: service.endPoint)
                        }
                    }
                }
            }
        })
    }
    
    func callServiceWith(url: String?) {
        print(url)
        manageServiceResponse()
    }
    
    func manageServiceResponse() {
        guard let path = Bundle.main.path(forResource: "serviceResponse", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let jsonObjct = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            else { return }
        
        let serviceResponse = ServiceResponseForm.decode(params: jsonObjct)
        
        serviceResponse?.components?.forEach({ [weak self] (response) in
            guard let row = form.rowBy(tag: response.component ?? "") else { return }
            
            if let singleValueResponse = response as? SingleValueResponse {
                row.baseValue = singleValueResponse.value
            }
            else if let multiValueResponse = response as? MultiValueResponse, let values = multiValueResponse.values {
                (row as? BasePickerRow)?.values = values
            }
            self?.tableView.reloadData()
        })

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

extension Array where Element == Relation.RelatedControl {
    func components() -> [String] {
        return map{ $0.component ?? "" }
    }
}

extension Array where Element == Relation.Values {
    func valueFor(code: String) -> Relation.Values? {
        filter{ $0.code == code }.first
    }
}

extension Array where Element: BaseRow {
    func allValid() -> Bool {
        return allSatisfy{ $0.isValid }
    }
    
    func areCompleted() -> Bool {
        return allSatisfy{ ($0.baseValue != nil) }
    }
}

extension BaseRow {
    func hide() {
        hidden = true
        evaluateHidden()
    }
    
    func show() {
        hidden = false
        evaluateHidden()
    }
}

extension Form {
    func toggleRowsWith(tags: [String]?, shouldHide: Bool = true) {
        guard let tagList = tags else { return }
        for row in allRows where tagList.contains(row.tag ?? "") {
            shouldHide ? row.hide() : row.show()
        }
    }
    
    // get rows from tags
    func rowsBy(tags: [String]?) -> [BaseRow]? {
        guard let tagValues = tags else { return nil }
        return allRows.filter{ tagValues.contains($0.tag ?? "") }
    }
}

