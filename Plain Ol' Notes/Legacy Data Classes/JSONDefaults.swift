//
//  NoteManagerDefaults.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 7/17/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

protocol Keyable {
    
    var key: String { get }
    
}

extension Notification.Name {
    
    static let jsonError = Notification.Name("JSON Error")
    
}

class JSONDefaults<T: Codable & Keyable> {
    
    func save(_ object: T) {
        do {
            let encodedObject = try JSONEncoder().encode(object)
            UserDefaults.standard.set(encodedObject, forKey: object.key)
        } catch {
            NotificationCenter.default.post(name: .jsonError, object: error)
        }
    }
    
    func getSaved() -> [T] {
        let dict = UserDefaults.standard.dictionaryRepresentation()
        var objects: [T] = []
        let decoder = JSONDecoder()
        for k in dict.keys {
            if let data = UserDefaults.standard.data(forKey: k) {
                do {
                    let object = try decoder.decode(T.self, from: data)
                    objects.append(object)
                } catch {
                    NotificationCenter.default.post(name: .jsonError, object: error)
                }
            }
        }
        return objects
    }
    
    func delete(_ object: T) {
        UserDefaults.standard.removeObject(forKey: object.key)
    }
    
}
