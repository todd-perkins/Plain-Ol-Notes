//
//  TPExtensions.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 7/11/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let noteBlue = UIColor(red: 0, green: 178.0 / 255.0, blue: 1, alpha: 1)
    static let noteDarkGray = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    static let noteLightGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
    static let noteLighterGray = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
    static let noteLightestGray = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
    
}

extension UIView {
    
    func anchor(top: NSLayoutYAxisAnchor? = nil, left: NSLayoutXAxisAnchor? = nil, bottom: NSLayoutYAxisAnchor? = nil, right: NSLayoutXAxisAnchor? = nil, centerX: NSLayoutXAxisAnchor? = nil, centerY: NSLayoutYAxisAnchor? = nil, padding: UIEdgeInsets = .zero, size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let top = top { topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true }
        if let left = left { leadingAnchor.constraint(equalTo: left, constant: padding.left).isActive = true }
        if let bottom = bottom { bottomAnchor.constraint(equalTo: bottom, constant: padding.bottom).isActive = true }
        if let right = right { trailingAnchor.constraint(equalTo: right, constant: padding.right).isActive = true }
        if let centerX = centerX { centerXAnchor.constraint(equalTo: centerX).isActive = true }
        if let centerY = centerY { centerYAnchor.constraint(equalTo: centerY).isActive = true }
        if size != .zero { setSize(width: size.width, height: size.height) }
    }
    
    func setSize(width: CGFloat, height: CGFloat) {
        if width != 0 { set(anchor: widthAnchor, to: width) }
        if height != 0 { set(anchor: heightAnchor, to: height) }
    }
    
    func set(anchor: NSLayoutDimension, to amount: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        anchor.constraint(equalToConstant: amount).isActive = true
    }
    
}

extension UITextView {
    
    func truncateAtFirstLineBreak() {
        if let indexOfFirstLineBreak = text.index(of: "\n") {
            text = String(text[text.startIndex..<indexOfFirstLineBreak])
        }
    }
    
}
