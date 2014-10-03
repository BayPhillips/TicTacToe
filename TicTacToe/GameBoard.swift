//
//  GameBoard.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/22/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation

public class GameBoard : NSObject, NSCopying {
    var data : [NSIndexPath: GamePiece]
    lazy var columns : [Int] = [0,1,2]
    lazy var rows : [Int] = [0,1,2]
    var emptyPieces: [GamePiece] {
        get {
            var empty = [GamePiece]()
            for column in columns {
                for row in rows {
                    let emptyPiece = pieceAt(row, y: column)
                    if emptyPiece.isOpen {
                        empty.append(emptyPiece)
                    }
                }
            }
            return empty
        }
    }
    
    override init() {
        data = [NSIndexPath: GamePiece]()
        super.init()
        
        for section in columns {
            for row in rows {
                data[NSIndexPath(forRow: row, inSection: section)] = GamePiece(X: section, Y: row)
            }
        }
    }
    
    override public var description : String {
        get {
            var boardString: String = "\n"
            for section in columns {
                for row in rows {
                    let piece = pieceAt(row, y: section)
                    if let player = piece.playerOwner {
                        boardString += player.pieceName
                    } else {
                        boardString += "_"
                    }
                }
                boardString += "\n"
            }
            return boardString
        }
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        var newBoard = GameBoard()
        newBoard.data = data
        return newBoard
    }
    
    public func pieceAt(x : Int, y : Int) -> GamePiece! {
        return data[NSIndexPath(forRow: y, inSection: x)] as GamePiece!
    }
    
    public func isOpen(x: Int, y: Int) -> Bool {
        return pieceAt(x, y: y).isOpen
    }
}