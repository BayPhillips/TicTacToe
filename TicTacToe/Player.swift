//
//  Player.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/22/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation
public class Player : NSObject {
    var name : String
    var pieceName : String
    var isCPU : Bool
    var displayName: String {
        get {
            let cpuString = isCPU ? " (CPU)" : ""
            return "\(name)\(cpuString)"
        }
    }
    
    init(playerName: String, cpu: Bool, pieceRepresentation: String) {
        name = playerName
        isCPU = cpu
        pieceName = pieceRepresentation
    }
}