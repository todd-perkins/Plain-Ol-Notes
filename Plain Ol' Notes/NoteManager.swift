//
//  NoteManager.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/28/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let migrationError = Notification.Name("Error Migrating Data")
    
}

class NoteMigrator {
    
    fileprivate var fileManager:FileManager
    fileprivate let documentsDirectory:URL?
    var allNotes:[Note] = []
    
    init() {
        fileManager = FileManager.default
        do {
            documentsDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            NotificationCenter.default.post(name: .migrationError, object: error)
            documentsDirectory = nil
        }
        migrateNotes()
    }
    
    func loadSavedNotes() {
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
            NotificationCenter.default.post(name: .migrationError, object: error)
        }
    }
    
    func migrateNotes() {
        loadSavedNotes()
        if allNotes.isEmpty {
            return
        }
        let jsonDefaults = JSONDefaults<Note>()
        for note in allNotes{
            jsonDefaults.save(note)
        }
        deleteAllOldNotes()
    }
    
    func deleteAllOldNotes() {
        do {
            let allFiles = try fileManager.contentsOfDirectory(atPath: documentsDirectory!.path)
            for file in allFiles {
                let fullURL = documentsDirectory!.appendingPathComponent(file)
                if fileManager.isDeletableFile(atPath: fullURL.path) {
                    do {
                        try fileManager.removeItem(atPath: fullURL.path)
                    } catch {
                        NotificationCenter.default.post(name: .migrationError, object: error)
                    }
                }
            }
        } catch {
            NotificationCenter.default.post(name: .migrationError, object: error)
        }
    }
    
}
