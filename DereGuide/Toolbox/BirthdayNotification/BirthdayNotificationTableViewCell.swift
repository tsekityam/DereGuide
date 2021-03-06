//
//  BirthdayNotificationTableViewCell.swift
//  DereGuide
//
//  Created by zzk on 16/8/15.
//  Copyright © 2016 zzk. All rights reserved.
//

import UIKit
import TTGTagCollectionView
import SnapKit

class CharaWithBirthdayView: UIView {
    
    let icon = CGSSCharaIconView()
    
    let birthdayLabel = UILabel()
    
    weak var delegate: CGSSIconViewDelegate? {
        didSet {
            icon.delegate = self.delegate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(icon)
        icon.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(48)
        }
        icon.isUserInteractionEnabled = false
        
        birthdayLabel.font = .systemFont(ofSize: 14)
        birthdayLabel.textColor = .darkGray
        birthdayLabel.textAlignment = .center
        birthdayLabel.adjustsFontSizeToFitWidth = true
        birthdayLabel.baselineAdjustment = .alignCenters
        birthdayLabel.text = " "
        addSubview(birthdayLabel)
        birthdayLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(icon.snp.bottom).offset(3)
        }
    }
    
    func setup(with chara: CGSSChar) {
        icon.charaID = chara.charaId
        birthdayLabel.text = "\(chara.birthMonth!)-\(chara.birthDay!)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol BirthdayNotificationTableViewCellDelegate:class {
    func charIconClick(_ icon:CGSSCharaIconView)
}

class BirthdayNotificationTableViewCell: UITableViewCell, TTGTagCollectionViewDelegate, TTGTagCollectionViewDataSource {
    
    var charas = [CGSSChar]()
    let leftLabel = UILabel()
    let collectionView = TTGTagCollectionView()
    var charaViews = NSCache<NSNumber, CharaWithBirthdayView>()
    
    weak var delegate: BirthdayNotificationTableViewCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        leftLabel.font = .systemFont(ofSize: 16)
        contentView.addSubview(leftLabel)
        leftLabel.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.top.equalTo(10)
        }
        
        collectionView.contentInset = .zero
        collectionView.verticalSpacing = 10
        collectionView.horizontalSpacing = 10
        contentView.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp.makeConstraints { (make) in
            make.left.equalTo(readableContentGuide)
            make.right.equalTo(readableContentGuide)
            make.top.equalTo(leftLabel.snp.bottom).offset(5)
            make.bottom.equalTo(-10)
        }
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(with charas: [CGSSChar], title: String) {
        self.charas = charas
        leftLabel.text = title
        collectionView.reload()
    }
    
    func numberOfTags(in tagCollectionView: TTGTagCollectionView!) -> UInt {
        return UInt(charas.count)
    }
    
    private func viewFor(index: Int) -> CharaWithBirthdayView {
        if let view = charaViews.object(forKey: NSNumber(value: index)) {
            return view
        } else {
            let view = CharaWithBirthdayView()
            charaViews.setObject(view, forKey: NSNumber(value: index))
            return view
        }
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, tagViewFor index: UInt) -> UIView! {
        let view = viewFor(index: Int(index))
        view.setup(with: charas[Int(index)])
        return view
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, sizeForTagAt index: UInt) -> CGSize {
        return CGSize(width: 48, height: 68)
    }
    
    func tagCollectionView(_ tagCollectionView: TTGTagCollectionView!, didSelectTag tagView: UIView!, at index: UInt) {
        delegate?.charIconClick((tagView as! CharaWithBirthdayView).icon)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        layoutIfNeeded()
        collectionView.invalidateIntrinsicContentSize()
        return super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
    
}
