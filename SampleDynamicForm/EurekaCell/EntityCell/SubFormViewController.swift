//
//  SubFormViewController.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/28/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit
import Eureka

class SubFormViewController: FormViewController {
    var formValues: [String: Any] = [:]
    var onDismissCallback: ((SubFormViewController) -> Void)?
    
    var rows: [DynamicRow]? {
        didSet {
            initializeForm()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func initializeForm() {
        guard let rows = rows else { return }
        let section = Section()
        form +++ section
        
        rows.forEach { (dynamicRow) in
            if let row = dynamicRow.row {
                section <<< row
            }
        }
    }
    
    @IBAction func buttonActionAdd(_ sender: Any) {
        form.allRows.forEach { (row) in
            if let tag = row.tag {
                let value = form.value(for: tag) ?? ""
                formValues[tag] = value
            }
        }
        onDismissCallback?(self)
    }
   

}
