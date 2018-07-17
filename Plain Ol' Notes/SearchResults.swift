//
//  SearchResults.swift
//  Plain Ol' Notes
//
//  Created by Todd Perkins on 7/17/18.
//  Copyright © 2018 Todd Perkins. All rights reserved.
//

import UIKit

class SearchResults: UITableViewController {
    
    let cellID = "searchCell"
    var results: [String] = []
    
    override init(style: UITableViewStyle) {
        super.init(style: .plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)!
        cell.textLabel?.text = "Test"
        return cell
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
