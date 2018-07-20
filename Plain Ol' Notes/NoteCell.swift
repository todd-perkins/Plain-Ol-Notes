//
//  NoteCell.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/27/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

class NoteCell: UICollectionViewCell {
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .noteDarkGray
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = .clear
        return textView
    }()
    
    let titleTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .noteDarkGray
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.boldSystemFont(ofSize: 21)
        textView.backgroundColor = .clear
        return textView
    }()
    
    let creationDateTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .noteBlue
        textView.isUserInteractionEnabled = false
        textView.font = UIFont.systemFont(ofSize: 11)
        textView.backgroundColor = .clear
        return textView
    }()
    
    var cdNote: CDNote? {
        didSet {
            guard let cdNote = cdNote, let lastModfied = cdNote.lastModifiedDate else { return }
            textView.text = cdNote.text
            creationDateTextView.text = "Modified \(dayInRelationToToday(date: lastModfied))"
            titleTextView.text = cdNote.title
        }
    }
    
    func dayInRelationToToday(date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        }
        else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }
        else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfDate = calendar.startOfDay(for: date)
            let components = calendar.dateComponents([Calendar.Component.day], from: startOfNow, to: startOfDate)
            if let days = components.day {
                return "\(abs(days)) days ago"
            }
        }
        return ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        contentView.addSubview(titleTextView)
        contentView.addSubview(textView)
        contentView.addSubview(creationDateTextView)
        
        let contentViewCornerRadius: CGFloat = 10
        contentView.layer.cornerRadius = contentViewCornerRadius
        
        let contentViewBottomPadding: CGFloat = 35
        textView.anchor(top: titleTextView.bottomAnchor, left: contentView.leadingAnchor, bottom: contentView.bottomAnchor, right: contentView.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -contentViewBottomPadding, right: 0))
        
        let creationDateHeight: CGFloat = 30
        creationDateTextView.anchor(left: contentView.leadingAnchor, bottom: contentView.bottomAnchor, right: contentView.trailingAnchor, padding: .zero, size: CGSize(width: 0, height: creationDateHeight))
        
        let titleTextHeight:CGFloat = 32
        titleTextView.anchor(top: contentView.topAnchor, left: contentView.leadingAnchor, bottom: nil, right: contentView.trailingAnchor, centerX: nil, centerY: nil, padding: .zero, size: CGSize(width: 0, height: titleTextHeight))
    }
    
}
