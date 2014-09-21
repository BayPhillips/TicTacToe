//
//  TicTacToeGameManager.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/21/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation

class GameBoard : NSObject, NSCopying {
    var data : Dictionary<NSIndexPath, GamePiece>
    lazy var Columns : [Int] = [0,1,2]
    lazy var Rows : [Int] = [0,1,2]
    
    override init() {
        data = Dictionary<NSIndexPath, GamePiece>()
        super.init()
        
        for section in Columns {
            for row in Rows {
                data[NSIndexPath(forRow: row, inSection: section)] = GamePiece(x: section, y: row)
            }
        }
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        var newBoard : GameBoard = GameBoard()
        newBoard.data = data
        return newBoard
    }
    
    func PieceAt(x : Int, y : Int) -> GamePiece! {
        return data[NSIndexPath(forRow: y, inSection: x)] as GamePiece!
    }
    
    func IsOpen(x: Int, y: Int) -> Bool {
        return PieceAt(x, y: y).IsOpen()
    }
    
    func EmptyPieces() -> [GamePiece] {
        var empty = [GamePiece]()
        for column in self.Columns {
            for row in self.Rows {
                let emptyPiece = self.PieceAt(row, y: column)
                if emptyPiece.IsOpen() {
                    empty.append(emptyPiece)
                }
            }
        }
        return empty
    }
}

class Player : NSObject {
    var Name : NSString
    var IsCPU : Bool
    
    init(name: NSString, isCPU: Bool) {
        Name = name
        IsCPU = isCPU
    }
    
    func DisplayName() -> String! {
        let cpuString = IsCPU ? " (CPU)" : ""
        return "\(Name)\(cpuString)"
    }
}

class GamePiece : NSObject, NSCopying {
    var PlayerOwner : Player?
    var X : Int
    var Y : Int
    
    init(x: Int, y : Int) {
        X = x
        Y = y
        super.init()
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        var newPiece : GamePiece = GamePiece(x: X, y: Y)
        newPiece.PlayerOwner = PlayerOwner
        return newPiece
    }
    
    func IsOpen() -> Bool {
        return PlayerOwner == nil
    }
}