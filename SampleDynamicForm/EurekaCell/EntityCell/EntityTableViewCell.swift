//
//  EntityTableViewCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 8/29/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit

class EntityTableViewCell: UITableViewCell {
    var data: [String: String]?
    var entity: Entity?

    @IBOutlet weak var stackView: UIStackView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        addExtraFields()
    }
    
    func addExtraFields() {
        stackView?.removeFirstArrangedView()
        guard let extraFields = entity?.extraFields, !extraFields.isEmpty else { return }
        for field in extraFields {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: 50))
            label.text = "\(field.key): \(field.value)"
            stackView?.addArrangedSubview(label)
        }
    }
    
}


