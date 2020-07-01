//
//  ChatViewController.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 12/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class ChatViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    weak var databaseController: DatabaseProtocol?
    
    var sender: Sender?
    var conversation: Conversation?
    var messagesList = [ConversationMessage]()
    
    var conversationRef: CollectionReference?
    var databaseListener: ListenerRegistration?
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm dd/MM/yy"
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        // Initilize delegate
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messageInputBar.delegate = self
        
        if conversation != nil {
            let database = Firestore.firestore()
            conversationRef = database
                .collection("conversations")
                .document(conversation!.id)
                .collection("messages")
            navigationItem.title = conversation!.name
        }
        
        let currentUser = databaseController?.getCurrentUser()
        self.sender = Sender(id: (currentUser?.id)!, name: (currentUser?.name)!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // listen for changes in message list
        databaseListener = conversationRef?.order(by: "time").addSnapshotListener { (querySnapshot, error) in
            if error != nil {
                print(error!)
                return
            }
            querySnapshot?.documentChanges.forEach({ change in
                // parse the message
                if change.type == .added {
                    let snapshot = change.document
                    let id = snapshot.documentID
                    let senderId = snapshot["senderId"] as! String
                    let senderName = snapshot["senderName"] as! String
                    let messageText = snapshot["text"] as! String
                    let sentTimestamp = snapshot["time"] as! Timestamp
                    let sentDate = sentTimestamp.dateValue()
                    
                    let sender = Sender(id: senderId, name: senderName)
                    let message = ConversationMessage(sender: sender, messageId: id, sentDate: sentDate, message: messageText)
                    self.messagesList.append(message)
                    self.messagesCollectionView.insertSections([self.messagesList.count-1])
                }
            })
            
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    // remove listener on disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseListener?.remove()
    }
    
    func currentSender() -> SenderType {
        return self.sender!
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messagesList[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messagesList.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name,
                                  attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString,
                                  attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text.isEmpty {
            return
        }
        
        conversationRef?.addDocument(data: [
            "senderId": sender!.senderId,
            "senderName": sender!.displayName,
            "text": text,
            "time": Timestamp(date: Date.init())
        ])
        
        inputBar.inputTextView.text = ""
    }
    
    // Mark: MessagesLayoutDelegate
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }

}
