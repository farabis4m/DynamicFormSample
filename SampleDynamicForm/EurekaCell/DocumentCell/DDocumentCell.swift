//
//  DDocumentCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 7/4/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class DDocumentCell: DBaseCell {

    @IBOutlet weak var view: UIView?
    
    override func setup() {
        super.setup()
        
        //selectionStyle = .none
        backgroundColor = .clear
        view?.layer.cornerRadius = 5
    }
    
    override func update() {
        super.update()
        
        guard let row = row as? DDocumentRow else { return }
        titleLabel?.accessibilityIdentifier = "labelTitle"
        titleLabel?.text = row.title
    }
    
}

final class DDocumentRow: DBaseRow, RowType {

    public typealias PresentedControllerType = CustomCameraViewController
    
    var presentationMode: PresentationMode<PresentedControllerType>?
    
    var onPresentCallback: ((FormViewController, PresentedControllerType) -> Void)?
    
    var documentCount = 0
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<DBaseCell>(nibName: DDocumentCell.identifier)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return CustomCameraViewController { (_) in }
            }, onDismiss: { (viewController) in
                if let customCameraVC = viewController as? CustomCameraViewController {
                    print(customCameraVC.documents)
                }
                viewController.dismiss(animated: true, completion: nil)
//                _ = viewController.navigationController?.popViewController(animated: true)
        })
        
        self.onRowValidationChanged { [weak self] (_, _) in
            self?.validateRowError()
        }
    }
    
    convenience init(param: [String: Any]) {
        self.init(tag: (param["tag"] as? String) ?? "")
        self.placeholder = (param["hint"] as? String) ?? ""
        self.title = (param["title"] as? String) ?? ""
        self.documentCount = Int((param["documentCount"] as? String) ?? "0") ?? 0
        
        if let validation = param["validations"] as? [[String: Any]] {
            self.addValidation(params: validation)
        }
        
        if let arrayValues = (param["values"]) as? [[String:String]] {
            createListableValues(arrayValues: arrayValues)
        }
    }
    
    override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = title
            controller.onDismissCallback = presentationMode.onDismissCallback
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }
}
