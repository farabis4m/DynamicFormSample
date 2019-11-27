//
//  DEntityTableViewCell.swift
//  SampleDynamicForm
//
//  Created by Lincy Francis on 9/8/19.
//  Copyright © 2019 Jafar Khan. All rights reserved.
//

import UIKit

class DEntityTableViewCell: UITableViewCell {
    var rows: [SubFormResponse]?
    
    @IBOutlet weak var leftStackView: UIStackView?
    @IBOutlet weak var rightStackView: UIStackView?
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
        leftStackView?.removeFirstArrangedView()
        rightStackView?.removeFirstArrangedView()
        guard let rows = rows else { return }
        for row in rows {
            guard let rowPattern = row.rowPattern else { continue }
            let label = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: 200, height: 50)))
            label.text = row.value
            if rowPattern.alignment == .right {
                label.textAlignment = .right
                rightStackView?.addArrangedSubview(label)
            } else {
                leftStackView?.addArrangedSubview(label)
            }
        }
        layoutSubviews()
    }
    
}

extension UIStackView {
    func removeFirstArrangedView() {
        for item in arrangedSubviews {
            removeArrangedSubview(item)
            item.removeFromSuperview()
        }
    }
}
