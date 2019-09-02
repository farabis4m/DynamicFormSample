//
//  EntityExpenseTableViewCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 9/1/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit

class EntityExpenseTableViewCell: EntityTableViewCell {
    
    @IBOutlet weak var labelExpense: UILabel?
    @IBOutlet weak var labelDate: UILabel?
    @IBOutlet weak var extraStackView: UIStackView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func configureCell() {
        super.configureCell()
        guard let expense = entity as? Expense else { return }
        labelExpense?.text = expense.expenseType
//        labelDate?.text = expense.reason
//        addExtraFields()
    }
    
//    func addExtraFields() {
//        guard let extraFields = entity?.extraFields, !extraFields.isEmpty else { return }
//        for field in extraFields {
//            let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
//            label.text = "\(field.key): \(field.value)"
//            extraStackView?.addArrangedSubview(label)
//        }
//    }
    
}
