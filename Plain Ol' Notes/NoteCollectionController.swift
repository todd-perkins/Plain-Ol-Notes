//
//  NoteCollectionController.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/27/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

extension Array where Iterator.Element == Note {
    
    func containsTitle(for note:Note) -> Bool {
        for n in self {
            if n.title == note.title && n != note {
                return true
            }
        }
        return false
    }
    
}

class NoteCollectionController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    fileprivate var notes: [Note] = []
    fileprivate var filteredNotes: [Note] = []
    fileprivate let searchController = UISearchController(searchResultsController: nil)
    fileprivate var isFiltering: Bool { return searchController.isActive && !searchController.searchBar.text!.isEmpty }
    fileprivate var currentNoteIndex = -1
    fileprivate let noteMigrator = NoteMigrator()
    fileprivate let noteManager = JSONDefaults<Note>()
    fileprivate let cellID = "noteCell"
    fileprivate let padding: CGFloat = 5
    fileprivate let columns: CGFloat = 2
    
    fileprivate let noteEditor: SingleNoteViewController = {
        let editor = SingleNoteViewController()
        return editor
    }()
    
    fileprivate let addButton: UIButton = {
        let btn = UIButton(type: UIButtonType.custom)
        btn.setImage(#imageLiteral(resourceName: "add_note"), for: .normal)
        btn.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(NoteCell.self, forCellWithReuseIdentifier: cellID)
        setupView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleError(notification:)), name: .jsonError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleError(notification:)), name: .migrationError, object: nil)
        notes = noteManager.getSaved()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if currentNoteIndex == -1 {
            return
        }
        
        if noteEditor.noteTitle == "" && noteEditor.noteText == "" {
            deleteCurrentNote()
        } else {
            updateCurrentNote()
            
            if noteEditor.noteTitle == "" || noteEditor.noteText == "" {
                let missingText = noteEditor.noteTitle == "" ? "a title" : "text"
                let alert = UIAlertController(title: "Missing Data", message: "Your note is missing \(missingText). Do you want to delete the note?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.selectAndShowNote(index: self.currentNoteIndex)
                }))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                    self.deleteCurrentNote()
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text?.localizedLowercase, !text.isEmpty {
            //let words: [String] = text.replacingOccurrences(of: "'", with: "").split(separator: " ").map({ String($0).localizedLowercase })
            let words: [String] = text.components(separatedBy: .punctuationCharacters)
                .joined()
                .components(separatedBy: .whitespacesAndNewlines)
                .filter({ !$0.isEmpty })
            print(words)
            
            filteredNotes = notes.filter { (note) -> Bool in
                let titleText = note.title.localizedLowercase.components(separatedBy: .punctuationCharacters).joined()
                let bodyText = note.text.localizedLowercase.components(separatedBy: .punctuationCharacters).joined()
                for word in words {
                    if !titleText.contains(word) && !bodyText.contains(word) {
                        return false
                    }
                }
                return true
            }
        }
        collectionView?.reloadData()
    }
    
    fileprivate func deleteCurrentNote() {
        noteManager.delete(notes[currentNoteIndex])
        notes.remove(at: currentNoteIndex)
        collectionView?.deleteItems(at: [currentNoteIndexPath()])
    }
    
    fileprivate func updateCurrentNote() {
        var note = notes[currentNoteIndex]
        note.text = noteEditor.noteText
        note.title = noteEditor.noteTitle
        var i = 1
        let originalTitle = note.title
        while notes.containsTitle(for: note) {
            note.title = originalTitle + " (\(i))"
            i += 1
        }
        note.lastModifiedDate = Date()
        notes[currentNoteIndex] = note
        collectionView?.reloadItems(at: [currentNoteIndexPath()])
        noteManager.save(note)
    }
    
    @objc fileprivate func addNote() {
        let note = Note(text: "", title: "", creationDate: Date(), lastModifiedDate: Date())
        notes.append(note)
        noteManager.save(note)
        currentNoteIndex = notes.count - 1
        collectionView?.insertItems(at: [currentNoteIndexPath()])
        selectAndShowNote(index: notes.count - 1)
    }
    
    fileprivate func currentNoteIndexPath() -> IndexPath {
        return IndexPath(item: currentNoteIndex, section: 0)
    }
    
    fileprivate func selectAndShowNote(index: Int) {
        if index >= notes.count || (isFiltering && index >= filteredNotes.count) {
            return
        }
        currentNoteIndex = index
        let note = isFiltering ? filteredNotes[currentNoteIndex] : notes[currentNoteIndex]
        noteEditor.noteText = note.text
        noteEditor.noteTitle = note.title
        navigationController?.pushViewController(noteEditor, animated: true)
    }
    
    fileprivate func setupButton() {
        view.addSubview(addButton)
        
        let buttonWidth: CGFloat = 75
        let buttonPadding: CGFloat = 10
        addButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.trailingAnchor, padding: .init(top: 0, left: 0, bottom: -buttonPadding, right: -buttonPadding), size: CGSize(width: buttonWidth, height: buttonWidth))
    }
    
    fileprivate func setupView() {
        collectionView?.backgroundColor = .noteLightGray
        collectionView?.contentInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        navigationController?.navigationBar.tintColor = .noteBlue
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.noteDarkGray]
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.noteDarkGray]
        setupButton()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        collectionView?.allowsMultipleSelection = editing
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditing {
            return
        }
        selectAndShowNote(index: indexPath.item)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isFiltering ? filteredNotes.count : notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width / columns - padding * 1.5
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return padding
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! NoteCell
        cell.contentView.backgroundColor = .white
        cell.note = isFiltering ? filteredNotes[indexPath.item] : notes[indexPath.item]
        return cell
    }
    
    @objc func handleError(notification: Notification) {
        if let error = notification.object as? Error {
            let alert = UIAlertController(title: notification.name.rawValue, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
}
