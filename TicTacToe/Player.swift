//
//  Player.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/22/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation
class Player : NSObject {
    var name : NSString
    var isCPU : Bool
    var displayName: String {
        get {
            let cpuString = isCPU ? " (CPU)" : ""
            return "\(name)\(cpuString)"
        }
    }
    
    init(playerName: NSString, cpu: Bool) {
        name = playerName
        isCPU = cpu
    }
}