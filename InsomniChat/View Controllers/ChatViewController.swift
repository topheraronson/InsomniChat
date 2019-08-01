//
//  ChatViewController.swift
//  InsomniChat
//
//  Created by Christopher Aronson on 7/30/19.
//  Copyright © 2019 Christopher Aronson. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import FirebaseFirestore

class ChatViewController: MessagesViewController {

    let user: User
    let chatUser: ChatUser
    let chatRoomName: String
    var messages = [Message]()
    
    let refreshControl = UIRefreshControl()
    
    let db = Firestore.firestore()
    var reference: CollectionReference?
    var messageListener: ListenerRegistration?
    
    init(user: User, displayName: String, chatRoomName: String) {
        
        self.chatUser = ChatUser(senderId: user.uid, displayName: displayName)
        self.user = user
        self.chatRoomName = chatRoomName
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("How did you get here?")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reference = db.collection("chatRooms").document(chatRoomName).collection("thread")
        
        messageListener = reference?.addSnapshotListener{ query, error in
            
            guard let query = query else {
                print("Error listingin for updates: \(error?.localizedDescription ?? "No Error")")
                return
            }
            
            query.documentChanges.forEach { change in
//                self.handleChange(change)
            }
        }

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
//        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    private func save(message: Message) {
        
        var messageText = ""
        
        switch message.kind {
        case .text( let message):
            messageText = message
        default:
            break
        }
        
        let messageJSON = ["message": messageText, "messageID": message.messageId, "senderName": message.sender.displayName, "senderID": user.uid,"sendTime": message.sentDate] as [String : Any]
        
        reference?.addDocument(data: messageJSON, completion: { error in
            
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
            
            self.messagesCollectionView.scrollToBottom()
        })
    }
    
    private func insert(message: Message) {
        
//        guard !messages.contains(message) else { return }
        
        messages.append(message)
//        messages.sort()
        
        
        
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom()
        }
    }

    
//    private func handleChange(_ change: DocumentChange) {
    
//        let messageJSON = change.document.data()
//
//        guard let id = messageJSON["messageID"] as? String,
//        let senderID = messageJSON["senderID"] as? String,
//        let messageText = messageJSON["message"] as? String,
//        let timestamp = messageJSON["sendTime"] as? Timestamp,
//        let senderName = messageJSON["senderName"] as? String
//        else { return }
//
//        let sendTime = timestamp.dateValue()
//
//        switch change.type {
//        case .added:
//
//            let sender = ChatUser(senderId:senderID, displayName: senderName)
//            let message = Message(user: <#T##User#>, displaName: <#T##String#>, content: <#T##String#>)
//
//            insert(message: message)
//        default:
//            break
//        }
//
//    }

}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {

        return chatUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.item]
    }
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .gray : .blue
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(corner, .curved)
    }
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        inputBar.inputTextView.text = ""
        
//        save(message: Message(user: user, content: ""))
        
    }
}

