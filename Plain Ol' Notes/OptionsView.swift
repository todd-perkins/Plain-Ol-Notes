//
//  AdditionalButtonsView.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 7/9/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

class OptionsView: UIView {
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "trash"), for: .normal)
        button.tintColor = .noteBlue
        return button
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "share"), for: .normal)
        button.tintColor = .noteBlue
        return button
    }()
    
    let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.tintColor = .noteBlue
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .noteLightestGray
        createLayout()
    }
    
    fileprivate func createLayout() {
        addSubview(deleteButton)
        addSubview(shareButton)
        
        let buttonSize: CGFloat = 30
        let buttonPadding: CGFloat = 10
        deleteButton.anchor(left: leadingAnchor, centerY: centerYAnchor, padding: .init(top: 0, left: buttonPadding, bottom: 0, right: 0), size: CGSize(width: buttonSize, height: buttonSize))
        shareButton.anchor(top: nil, left: nil, bottom: nil, right: trailingAnchor, centerX: nil, centerY: centerYAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: -buttonPadding), size: CGSize(width: buttonSize, height: buttonSize))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
