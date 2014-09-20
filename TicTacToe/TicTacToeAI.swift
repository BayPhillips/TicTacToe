//
//  TicTacToeAI.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/19/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation

class TicTacToeAI {
    var Manager : GameManager
    
    init(gameManager : GameManager) {
        Manager = gameManager
    }
    
    func MakeBestMove() {
        var moved : Bool = false
        // Check if I have two in a row anywhere and if so place it there
        // Horizontal
        for column in 0...2 {
            if(ColumnHasFreeSpaceAtEnd(column, forPlayer: Manager.Player2)) {
                Manager.PlacedPiece(NSIndexPath(forRow: 2, inSection: column))
                moved = true
                break
            }
        }
        // Diagonal
        // Vertical
        
        // Check if the opposing player has two in a row anywhere and if so place it there to Block
        // Horizontal
        // Diagonal
        // Vertical
        
        // Check if I can make a fork (two potential moves)
            // If I've placed one or more pieces
            //
    }
    
    func ColumnHasFreeSpaceAtEnd(column : Int, forPlayer : Player) -> Bool {
        let first = Manager.GameBoard[NSIndexPath(forRow: 0, inSection: column)] as GamePiece!
        let second = Manager.GameBoard[NSIndexPath(forRow: 1, inSection: column)] as GamePiece!
        let third = Manager.GameBoard[NSIndexPath(forRow: 2, inSection: column)] as GamePiece!
        return first.PlayerOwner == forPlayer && second.PlayerOwner == forPlayer && third.PlayerOwner == nil
    }
    
    func RowHasFreeSpace(row : Int) -> Bool {
        return false
    }
}