//
//  ChatUser.swift
//  InsomniChat
//
//  Created by Christopher Aronson on 7/30/19.
//  Copyright © 2019 Christopher Aronson. All rights reserved.
//

import Foundation
import MessageKit

struct ChatUser: SenderType {
    
    var senderId: String
    var displayName: String
}
