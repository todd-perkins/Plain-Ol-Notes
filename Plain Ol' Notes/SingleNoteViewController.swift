//
//  SingleNoteViewController.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/28/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

class SingleNoteViewController: UIViewController, UITextViewDelegate {
    
    fileprivate let textView: KMPlaceholderTextView = {
        let tView = KMPlaceholderTextView()
        tView.font = UIFont.systemFont(ofSize: 18)
        tView.textColor = .noteDarkGray
        tView.tintColor = .noteBlue
        tView.placeholder = "Note Text"
        return tView
    }()
    
    fileprivate let titleTextView: KMPlaceholderTextView = {
        let tView = KMPlaceholderTextView()
        tView.font = UIFont.boldSystemFont(ofSize: 22)
        tView.textColor = .noteDarkGray
        tView.tintColor = .noteBlue
        tView.placeholder = "Note Title"
        tView.textContainer.maximumNumberOfLines = 1
        tView.textContainer.lineBreakMode = .byTruncatingTail
        return tView
    }()
    
    fileprivate let optionsView = OptionsView()
    
    var noteTitle: String = "" {
        didSet {
            if titleTextView.text != noteTitle {
                titleTextView.text = noteTitle
            }
        }
    }
    
    var noteText: String = "" {
        didSet {
            if textView.text != noteText {
                textView.text = noteText
            }
        }
    }
    
    fileprivate func setupTextView() {
        view.addSubview(titleTextView)
        view.addSubview(textView)
        view.addSubview(optionsView)
        
        let leftRightPadding: CGFloat = 10
        let titleTextTopPadding: CGFloat = 20
        let titleTextHeight: CGFloat = 70
        textView.anchor(top: titleTextView.bottomAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: leftRightPadding, bottom: 0, right: -leftRightPadding))
        
        titleTextView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: titleTextTopPadding, left: leftRightPadding, bottom: titleTextHeight, right: -leftRightPadding))
        
        let optionsViewHeight: CGFloat = 60
        optionsView.anchor(top: view.safeAreaLayoutGuide.bottomAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: -optionsViewHeight, left: 0, bottom: 0, right: 0))
        
        let belowSafeAreaFillerView = UIView()
        view.addSubview(belowSafeAreaFillerView)
        belowSafeAreaFillerView.backgroundColor = .noteLightestGray
        belowSafeAreaFillerView.anchor(top: optionsView.bottomAnchor, left: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.bottomAnchor, right: view.safeAreaLayoutGuide.trailingAnchor)
        
        optionsView.deleteButton.addTarget(self, action: #selector(deleteNote), for: .touchUpInside)
        optionsView.shareButton.addTarget(self, action: #selector(shareNote), for: .touchUpInside)
        optionsView.doneButton.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextView.delegate = self
        textView.delegate = self
        view.backgroundColor = .white
        title = "Note"
        navigationItem.largeTitleDisplayMode = .never
        
        setupTextView()
    }
    
    @objc fileprivate func dismissKeyboard() {
        textView.resignFirstResponder()
        titleTextView.resignFirstResponder()
    }
    
    @objc fileprivate func shareNote() {
        noteTitle = titleTextView.text
        noteText = textView.text
        let msg = (noteTitle != "") ? "\(noteTitle)\n\(noteText)" : noteText
        guard msg != "" else {
            let alert = UIAlertController(title: "Nothing to Share", message: "You don't have any text to share.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            alert.view.tintColor = .noteBlue
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
            return
        }
        let items = [msg]
        let activityView = UIActivityViewController(activityItems: items, applicationActivities: nil)
        DispatchQueue.main.async {
            self.present(activityView, animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func deleteNote() {
        let alert = UIAlertController(title: "Delete Note", message: "Are you sure you want to delete this note? This cannot be undone.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
            self.textView.text = ""
            self.titleTextView.text = ""
            self.navigationController?.popToRootViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = .noteBlue
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if noteTitle == "" {
            titleTextView.becomeFirstResponder()
        } else if noteText == "" {
            textView.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textView.resignFirstResponder()
        noteText = textView.text
        noteTitle = titleTextView.text
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView === titleTextView {
            titleTextView.truncateAtFirstLineBreak()
        }
    }
    
}
