//
//  GamePiece.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/22/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation
public class GamePiece : NSObject, NSCopying {
    let x : Int
    let y : Int
    public var playerOwner : Player?
    var isOpen: Bool {
        get {
            return playerOwner == nil
        }
    }
    
    init(X: Int, Y : Int) {
        x = X
        y = Y
        super.init()
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        var newPiece : GamePiece = GamePiece(X: x, Y: y)
        newPiece.playerOwner = playerOwner
        return newPiece
    }
}