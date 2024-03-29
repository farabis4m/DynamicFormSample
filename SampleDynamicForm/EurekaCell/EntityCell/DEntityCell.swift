//
//  DEntityCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/28/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import Foundation
import Eureka

class DEntityCell: DBaseCell {
    
    @IBOutlet weak var labelEntity: UILabel?
    @IBOutlet weak var buttonAdd: UIButton?
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var heightConstraintTableView: NSLayoutConstraint?
    @IBOutlet weak var heightConstraintStackView: NSLayoutConstraint?
    @IBOutlet weak var stackView: UIStackView?
    
   /* var entityType: DynamicRow.EntityType? {
        return (row as? DEntityRow)?.entityType
    }
    
    var entities: [Entity]?*/
    
    var subRows: [[SubFormResponse]]? {
        return (row as? DEntityRow)?.resultRows
    }
    
    var entityRow: DEntityRow? {
        return (row as? DEntityRow)
    }
    
    override func setup() {
        super.setup()
        
        selectionStyle = .none
        backgroundColor = .clear
        tableView?.isHidden = true
        tableView?.dataSource = self
        tableView?.delegate = self
        /*tableView?.register(UINib(nibName: "EntityExpenseTableViewCell", bundle: nil), forCellReuseIdentifier: "EntityExpenseTableViewCell")
        tableView?.register(UINib(nibName: "EntityFamilyTableViewCell", bundle: nil), forCellReuseIdentifier: "EntityFamilyTableViewCell")*/
        tableView?.register(UINib(nibName: "DEntityTableViewCell", bundle: nil), forCellReuseIdentifier: "DEntityTableViewCell")
//        tableView?.estimatedRowHeight = 50//UITableView.automaticDimension
//        tableView?.rowHeight = UITableView.automaticDimension
        layoutIfNeeded()
    }
    
    override func update() {
        super.update()
        
       /* getEntityModel() */
        tableView?.reloadData()
        
        labelEntity?.text = row.title
        tableView?.isHidden = entityRow?.dataSource?.isEmpty ?? true
        perform(#selector(loadCell), with: self, afterDelay: 0.0)
        layoutSubviews()
//
    }
    
    @objc func loadCell() {
        self.layoutSubviews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !(tableView?.isHidden ?? true) {
            heightConstraintTableView?.constant = tableView?.contentSize.height ?? 40
            
        }
        let size = stackView?.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        print("stackview Size: \(size) tableview height: \(heightConstraintTableView?.constant)")
        heightConstraintStackView?.constant = size?.height ?? 50
        stackView?.layoutSubviews()
        print("stackview height: \(stackView?.frame.height)")
    }
    
  /*  func getEntityTypeCell() -> String? {
        guard let type = entityType else { return nil }
        switch type {
        case .expense:
            return "EntityExpenseTableViewCell"
        case .family:
            return "EntityFamilyTableViewCell"
        }
    }
    
    func getEntityModel() {
        guard let type = entityType, let dataSource = (row as? DEntityRow)?.dataSource, !dataSource.isEmpty else { return }
        entities = []
        for source in dataSource {
            if let entity = Entity.decode(entityType: type, params: source) {
                entities?.append(entity)
                
                var extraFields = [String: String]()
                
                for key in source.keys {
                    switch type {
                    case .expense:
                        if !Expense.CodingKeys.cases.contains(key) {
                            extraFields[key] = source[key] as? String
                        }
                    case .family:
                        if !Family.CodingKeys.cases.contains(key) {
                            extraFields[key] = source[key] as? String
                        }
                    }
                }
                entity.extraFields = extraFields
            }
        }
    }*/
    
    @IBAction func buttonActionAdd(_ sender: Any) {
    }
    
}

extension DEntityCell: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        /*return entities?.count ?? 0 */
        return subRows?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       /* guard let cellIdentifier = getEntityTypeCell(), let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? EntityTableViewCell else { return UITableViewCell() }
        cell.entity = entities?[indexPath.row]
        cell.configureCell()
        return cell*/
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DEntityTableViewCell", for: indexPath) as? DEntityTableViewCell else {
            return UITableViewCell()
        }
        cell.rows = subRows?[indexPath.row]
        cell.configureCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
}

final class DEntityRow: DBaseRow, RowType {
    public typealias PresentedController = SubFormViewController
    public var onPresentCallback: ((FormViewController, PresentedController) -> Void)?
    public var presentationMode: PresentationMode<PresentedController>?
    
    var subRows: [DynamicRow] = []
    var resultRows: [[SubFormResponse]] = []
    var dataSource: [[String: Any]]?
    var entityType: DynamicRow.EntityType?
    
    required init(tag: String?) {
        super.init(tag: tag)
        
        cellProvider = CellProvider<DBaseCell>(nibName: DEntityCell.identifier)
    }
    
    convenience init(row: DynamicEntityRow) {
        self.init(tag: row.tag)
        title = row.title
        entityType = row.entityType
        dataSource = []
        resultRows = []
        
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
            return PresentedController()
            }, onDismiss: { viewController in
                viewController.navigationController?.popViewController(animated: true)
        })
    }
    
    override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode {
            if let controller = presentationMode.makeController() {
                controller.rows = subRows
                
                controller.onDismissCallback = { [weak self] viewController in
                    self?.dataSource?.append(viewController.formValues)
                    self?.resultRows.append(viewController.subform)
                    self?.cell.update()
                    viewController.navigationController?.popViewController(animated: true)
                }
                
                presentationMode.present(controller, row: self, presentingController: cell.formViewController()!)
            } else {
                presentationMode.present(nil, row: self, presentingController: cell.formViewController()!)
            }
        }
    }
}

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

