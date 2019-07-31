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
    
    private var signOutButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Sign Out", for: .normal)
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        
        return button
    }()
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        if Auth.auth().currentUser != nil {
            print("\n\n\nalready logged in\n\n\n")
        }
        
        let stackView = UIStackView(arrangedSubviews: [usernameTextField, loginInButton, signOutButton])
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
            
            
            
            let vc = ChatViewController(user: user, displayName: displayName, chatRoomName: self.findChannel())
            self.present(vc, animated: true)
        }
        
        
    }
    
    @objc private func signOut() {
        
        do {
            try Auth.auth().signOut()
            print("signed out")
        } catch {
            print("Could not sign out")
        }
        
    }
    
    private func findChannel() -> String {
        
        var chatRoomID = ""
        
        db.collection("chatRooms").whereField("roomFull", isEqualTo: false).getDocuments { query, error in
            
            if let error = error {
                print("Error finding chat room: \(error.localizedDescription)")
                return
            }
            
            guard let document = query?.documents.first else {
                
                self.createChatRoom()
                return
            }
            
            // TODO: - add chat room id to user defaults
            
            chatRoomID = document.documentID
            self.db.collection("chatRooms").document(document.documentID).setData(["roomFull": true], merge: true)
        }
        
        return chatRoomID
    }
    
    private func createChatRoom() {
        
        print("making a chat room")
    }

}
