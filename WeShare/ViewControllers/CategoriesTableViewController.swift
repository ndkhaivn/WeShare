//
//  CategoriesTableViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 29/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

class CategoriesTableViewController: UITableViewController {

    let CATEGORY_CELL = "categoryCell"
    
    var categories: [Category] = []
    var pickCategoryDelegate: PickCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = generateCategories()
        tableView.reloadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func generateCategories() -> [Category] {
        var categories: [Category] = []
        categories.append(Category(name: "Money", systemIcon: "dollarsign.circle.fill"))
        categories.append(Category(name: "Tools", systemIcon: "wrench.fill"))
        categories.append(Category(name: "Household appliance", systemIcon: "house.fill"))
        categories.append(Category(name: "Groceries", systemIcon: "cart.fill"))
        categories.append(Category(name: "Clothing", systemIcon: "wrench.fill"))
        categories.append(Category(name: "Help", systemIcon: "paperplane.fill"))
        categories.append(Category(name: "Books", systemIcon: "book.fill"))
        categories.append(Category(name: "Medical", systemIcon: "waveform.path.ecg"))
        
        return categories
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        
        cell.categoryName.text = category.name!
        cell.categoryIcon.image = UIImage(systemName: category.systemIcon!)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pickCategoryDelegate?.pickCategory(category: categories[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
