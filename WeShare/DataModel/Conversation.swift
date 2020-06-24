//
//  Conversation.swift
//  WeShare
//
//  Created by Nguyễn Đình Khải on 12/6/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

class Conversation: NSObject {
    let id: String
    let name: String
    let listingID: String
    let userID: String
    let hostID: String
    
    init(id: String, name: String, listingID: String, userID: String, hostID: String) {
        self.id = id
        self.name = name
        self.listingID = listingID
        self.userID = userID
        self.hostID = hostID
    }
}

class Sender: SenderType {
    var senderId: String
    var displayName: String
    
    init(id: String, name: String) {
        senderId = id
        displayName = name
    }
}

class ConversationMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: Sender, messageId: String, sentDate: Date, message: String) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = .text(message)
    }
}
