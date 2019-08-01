//
//  DBRepresentation.swift
//  InsomniChat
//
//  Created by Christopher Aronson on 8/1/19.
//  Copyright © 2019 Christopher Aronson. All rights reserved.
//

import Foundation

protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}
