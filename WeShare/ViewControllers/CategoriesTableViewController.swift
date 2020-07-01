//
//  CategoriesTableViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 29/5/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit

// Provide a list of categories for user to pick from
class CategoriesTableViewController: UITableViewController {

    let CATEGORY_CELL = "categoryCell"
    
    var categories: [Category] = []
    var pickCategoryDelegate: PickCategoryDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        categories = generateCategories()
        tableView.reloadData()
    }

    func generateCategories() -> [Category] {
        var categories: [Category] = []
        categories.append(Category(name: "Money", systemIcon: "dollarsign.circle.fill"))
        categories.append(Category(name: "Tools", systemIcon: "wrench.fill"))
        categories.append(Category(name: "Household appliance", systemIcon: "house.fill"))
        categories.append(Category(name: "Groceries", systemIcon: "cart.fill"))
        categories.append(Category(name: "Clothing", systemIcon: "cube.box.fill"))
        categories.append(Category(name: "Help", systemIcon: "paperplane.fill"))
        categories.append(Category(name: "Books", systemIcon: "book.fill"))
        categories.append(Category(name: "Medical", systemIcon: "waveform.path.ecg"))
        
        return categories
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        
        // Each row has an icon and a text
        cell.categoryName.text = category.name!
        cell.categoryIcon.image = UIImage(systemName: category.systemIcon!)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // on select row - delegate the chosen category
        pickCategoryDelegate?.pickCategory(category: categories[indexPath.row])
        navigationController?.popViewController(animated: true)
    }

}
