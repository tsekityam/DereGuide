//
//  UnitAdvanceDescriptionCell.swift
//  DereGuide
//
//  Created by zzk on 2017/6/21.
//  Copyright © 2017 zzk. All rights reserved.
//

import UIKit
import SnapKit

class UnitAdvanceDescriptionCell: UITableViewCell {

    let leftLabel = UILabel()
    let rightLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
        }
        leftLabel.font = .systemFont(ofSize: 16)
        leftLabel.adjustsFontSizeToFitWidth = true
        leftLabel.baselineAdjustment = .alignCenters
        
        contentView.addSubview(rightLabel)
        rightLabel.snp.makeConstraints { (make) in
            make.right.equalTo(readableContentGuide)
            make.top.equalTo(10)
            make.left.equalTo(leftLabel.snp.right)
        }
        rightLabel.font = .systemFont(ofSize: 16)
        rightLabel.textColor = .darkGray
        
        leftLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        rightLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        leftLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        rightLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        selectionStyle = .none
    }
    
    func setupWith(leftString: String, rightString: String) {
        leftLabel.text = leftString
        rightLabel.text = rightString
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
