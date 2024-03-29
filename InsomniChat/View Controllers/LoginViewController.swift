//
//  LoginViewController.swift
//  InsomniChat
//
//  Created by Christopher Aronson on 7/30/19.
//  Copyright © 2019 Christopher Aronson. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

@objc(KRCLoginViewController)
class LoginViewController: UIViewController {

    private var usernameTextField: UITextField = {
        
        let textField = UITextField()
        textField.placeholder = "Tonights Username"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        
        return textField
    }()
    
    private var loginInButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Join Chat", for: .normal)
        button.addTarget(self, action: #selector(signIn), for: .touchUpInside)
        
        return button
    }()
    
//    private var signOutButton: UIButton = {
    
//        let button = UIButton(type: .system)
//        button.setTitle("Sign Out", for: .normal)
//        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
//
//        return button
//    }()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.0)
        
        if Auth.auth().currentUser != nil {
            
//            signInNow()
        }
        
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, loginInButton])
//        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -24).isActive = true
        stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 24).isActive = true
    }
    
    @objc private func signIn() {
        
        guard let displayName = usernameTextField.text, !displayName.isEmpty else { return }
        
         print("join tapped")
        
        Auth.auth().signInAnonymously { (results, error) in
            
            if let error = error {
                print("Could not sign in: \(error.localizedDescription)")
                return
            }
            
            guard let user = results?.user else { return }
            
            UserDefaults.standard.set(displayName, forKey: "displayName")
            
            self.findChannel(completion: { (chatRoomName, error) in
                
                if let error = error {
                    print("Error putting user into chat room: \(error)")
                    return
                }
                
                guard let chatRoomName = chatRoomName else { return }
                
                let vc = ChatViewController(user: user, displayName: displayName, chatRoomName: chatRoomName)
                let nav = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true)
                
                
            })
            

        }
        
        
    }
    
//    @objc private func signOut() {
//
//        do {
//            try Auth.auth().signOut()
//            print("signed out")
//        } catch {
//            print("Could not sign out")
//        }
//
//    }

    private func signInNow() {
        
        Auth.auth().signInAnonymously { (results, error) in
            
            if let error = error {
                print("Could not sign in: \(error.localizedDescription)")
                return
            }
                
            guard let user = results?.user,
            let displayName = UserDefaults.standard.string(forKey: "displayName"),
            let chatRoomName = UserDefaults.standard.string(forKey: "chatRoom")
            else { return }
            
            let vc = ChatViewController(user: user, displayName: displayName, chatRoomName: chatRoomName)
            self.present(vc, animated: true)
        }
    }
    
    private func findChannel(completion: @escaping (String?, Error?) -> Void) {
        
        db.collection("chatRooms").whereField("roomFull", isEqualTo: false).getDocuments { query, error in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let document = query?.documents.first else {
                
                self.createChatRoom(completion: { (chatRoom, error) in
                    
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    UserDefaults.standard.set(chatRoom, forKey: "chatRoom")
                    completion(chatRoom, nil)
                })
                return
            }
            
            
            UserDefaults.standard.set(document.documentID, forKey: "chatRoom")
            self.db.collection("chatRooms").document(document.documentID).setData(["roomFull": true], merge: true)
            completion(document.documentID, nil)
        }
    }
    
    private func createChatRoom(completion: @escaping (String?, Error?) -> Void) {
        
        var ref: DocumentReference?
        
        ref = db.collection("chatRooms").addDocument(data: ["roomFull": false]) { (error) in
            
            if let error = error {
                completion(nil, error)
                return
            }
            
            completion(ref!.documentID, nil)
        }
    }

}
