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

class ChatViewController: MessagesViewController {

    let user: User
    let chatUser: ChatUser
    let chatRoomName: String
    var messages = [Message]()
    
    let refreshControl = UIRefreshControl()
    
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
        
        print(message.kind)
        
    }
    
    private func insert(message: Message) {
        
    }

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
    
    
//    func currentSender() -> SenderType {
//
//        guard let user = user,
//        let displayName = UserDefaults.standard.string(forKey: "displayName")
//        else {
//            fatalError("No user")
//        }
//
//        //return Sender(id: user.uid, displayName: displayName)
//
//        return SenderType
//    }
//
//    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
//        return messages[indexPath.section]
//    }
//
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//        let name = message.sender.displayName
//
//        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: UIColor(white: 0.3, alpha: 1)])
//    }
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
        
        save(message: Message(sender: chatUser, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text)))
        
    }
}

