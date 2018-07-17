//
//  Note.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 6/27/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import Foundation

struct Note: Codable, Keyable {
    
    var text: String
    var title: String
    let creationDate: Date
    var lastModifiedDate: Date
    var key: String { return creationDate.description }
    
    static func ==(lhs:Note, rhs:Note) -> Bool {
        return lhs.creationDate == rhs.creationDate
    }
    
    static func !=(lhs:Note, rhs:Note) -> Bool {
        return lhs.creationDate != rhs.creationDate
    }
    
}
