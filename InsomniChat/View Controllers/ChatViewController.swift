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
import FirebaseAuth

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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOutTapped))
        
        reference = db.collection("chatRooms").document(chatRoomName).collection("thread")
        
        messageListener = reference?.addSnapshotListener{ query, error in
            
            guard let query = query else {
                print("Error listingin for updates: \(error?.localizedDescription ?? "No Error")")
                return
            }
            
            query.documentChanges.forEach { change in
                self.handleChange(change)
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
    
    @objc private func signOutTapped() {
        
        do {
            
            try Auth.auth().signOut()
            dismiss(animated: true)
        } catch {
            print("Could not log out")
        }
    }
    
    private func save(message: Message) {
        
        reference?.addDocument(data: message.representation) { error in
            
            if let error = error {
                print("Error uploading message to db: \(error.localizedDescription)")
                return
            }
            
            self.messagesCollectionView.scrollToBottom()
        }
    }
    
    private func insert(message: Message) {
        
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        
        
        
        messagesCollectionView.reloadData()
        
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func handleChange(_ change: DocumentChange) {
        
        guard change.type == .added else { return }
        
        let data = change.document.data()
        
        guard let sentDate = data["created"] as? Timestamp else { return }
        guard let senderID = data["senderID"] as? String else { return }
        guard let senderName = data["senderName"] as? String else { return }
        guard let content = data["content"] as? String else { return}
        
        let id = change.document.documentID
        
        
        let message = Message(displaName: senderName, content: content, senderID: senderID, sendDate: sentDate.dateValue(), messageID: id)
        
        insert(message: message)
    }
}

extension ChatViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }
    
    func currentSender() -> SenderType {

        return chatUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.item]
    }
    
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

}


// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .blue : .gray
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
        
        guard let displayName = UserDefaults.standard.string(forKey: "displayName") else { return }
        
        save(message: Message(user: user, displaName: displayName, content: text))
        
    }
}

