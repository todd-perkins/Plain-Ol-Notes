//
//  NoteManager.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/28/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import Foundation

enum NoteError: Error {
    case noteDoesNotExist
}

extension Array where Iterator.Element == Note {
    
    func findChangedTitle(for note:Note) -> Note? {
        for n in self {
            if n == note && n.title != note.title {
                return n
            }
        }
        return nil
    }
    
    func containsTitle(for note:Note) -> Bool {
        for n in self {
            if n.title == note.title && n != note {
                return true
            }
        }
        return false
    }
    
}

class NoteManager {
    
    fileprivate var fileManager:FileManager
    fileprivate let documentsDirectory:URL?
    var allNotes:[Note] = []
    
    init() {
        fileManager = FileManager.default
        do {
            documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            //NotificationCenter.default.post(name: .dataError, object: error)
            documentsDirectory = nil
        }
    }
    
    fileprivate func renameNoteIfTitleChanged(_ note: Note) {
        if let renamedNote = allNotes.findChangedTitle(for: note) {
            let newURL = documentsDirectory!.appendingPathComponent("\(note.title).txt")
            let oldURL = documentsDirectory!.appendingPathComponent("\(renamedNote.title).txt")
            do {
                try fileManager.moveItem(at: oldURL, to: newURL)
            } catch {
                //NotificationCenter.default.post(name: .dataError, object: error)
            }
        }
    }
    
    func saveNote(_ note:Note ) {
        let fileName = note.title.appending(".txt")
        let fileURL = documentsDirectory!.appendingPathComponent("\(fileName)")
        renameNoteIfTitleChanged(note)
        do {
            try note.text.write(to: fileURL, atomically: true, encoding: .utf8)
            try fileManager.setAttributes([FileAttributeKey.creationDate:note.creationDate,FileAttributeKey.modificationDate:note.lastModifiedDate], ofItemAtPath: fileURL.path)
        } catch {
            //NotificationCenter.default.post(name: .dataError, object: error)
        }
    }
    
    func getSavedNotes() -> [Note] {
        allNotes = []
        
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: documentsDirectory!.path)
            for file in allFiles {
                let index = file.index(file.endIndex, offsetBy: -5)
                let fileNameWithoutExtension = file[file.startIndex...index]
                let fullURL = documentsDirectory!.appendingPathComponent(file)
                if fileManager.fileExists(atPath: fullURL.path) {
                    let data = try fileManager.attributesOfItem(atPath: fullURL.path)
                    let creationDate = data[FileAttributeKey.creationDate] as! Date
                    let modificationDate = data[FileAttributeKey.modificationDate] as! Date
                    let content = try String(contentsOfFile: fullURL.path)
                    let note = Note(text: content, title: String(fileNameWithoutExtension), creationDate: creationDate, lastModifiedDate: modificationDate)
                    allNotes.append(note)
                }
            }
        } catch {
            //NotificationCenter.default.post(name: .dataError, object: error)
        }
        return allNotes
    }
    
    func delete(atIndex index: Int) throws {
        guard let note = note(atIndex: index) else {
            throw NoteError.noteDoesNotExist
        }
        let fileName = note.title.appending(".txt")
        let fullURL = documentsDirectory!.appendingPathComponent(fileName)
        if fileManager.isDeletableFile(atPath: fullURL.path) {
            do {
                try fileManager.removeItem(atPath: fullURL.path)
                allNotes.remove(at: index)
            } catch {
                //NotificationCenter.default.post(name: .dataError, object: error)
            }
        }
    }
    
    func note(atIndex index: Int) -> Note? {
        return (allNotes.count <= index || index < 0) ? nil : allNotes[index]
    }
    
}
