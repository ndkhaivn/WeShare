//
//  AllChatTableViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 12/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import Firebase

class AllChatTableViewController: UITableViewController {

    weak var databaseController: DatabaseProtocol?
    
    var conversations = [Conversation]()
    
    override func viewDidLoad() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        super.viewDidLoad()

        let user = databaseController?.getCurrentUser()
        databaseController?.getConversations(userID: (user?.id)!).then{ result in
            self.conversations = result
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return conversations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationCell", for: indexPath)
        let conversation = conversations[indexPath.row]
        cell.textLabel?.text = conversation.name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let conversation = conversations[indexPath.row]
        performSegue(withIdentifier: "chatSegue", sender: conversation)
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatSegue" {
            let sender = sender as! Conversation
            let destination = segue.destination as! ChatViewController
            destination.conversation = sender
        }
    }

}
