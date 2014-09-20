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
        // Check if I have two in a row anywhere and if so place it there
        // Vertical
        for column in Manager.Board.Columns {
            if let freePiece = FreePieceInColumn(column, forPlayer: Manager.Player2) {
                Manager.PlacedPiece(freePiece.X, y : freePiece.Y)
                return
            }
        }
        
        // Horizontal
        for row in Manager.Board.Rows {
            if let freePiece = FreePieceInRow(row, forPlayer: Manager.Player2) {
                Manager.PlacedPiece(freePiece.X, y : freePiece.Y)
                return
            }
        }
        
        // Diagonal
        if let piece = FreeDiagonalPiece(Manager.Player2) {
            Manager.PlacedPiece(piece.X, y: piece.Y)
            return
        }

        // Check if the opposing player has two in a row anywhere and if so place it there to Block
        // Vertical
        for column in Manager.Board.Columns {
            if let freePiece = FreePieceInColumn(column, forPlayer: Manager.Player1) {
                Manager.PlacedPiece(freePiece.X, y : freePiece.Y)
                return
            }
        }
        
        // Horizontal
        for row in Manager.Board.Rows {
            if let freePiece = FreePieceInRow(row, forPlayer: Manager.Player1) {
                Manager.PlacedPiece(freePiece.X, y : freePiece.Y)
                return
            }
        }
        
        // Diagonal
        if let piece = FreeDiagonalPiece(Manager.Player1) {
            Manager.PlacedPiece(piece.X, y: piece.Y)
            return
        }
        
        // Check if I can make a fork (two potential moves)
            // If I've placed one or more pieces
            //
    }
    
    func FreePieceInColumn(column : Int, forPlayer : Player) -> GamePiece? {
        let first = Manager.Board.PieceAt(column, y:0) as GamePiece!
        let second = Manager.Board.PieceAt(column, y:1) as GamePiece!
        let third = Manager.Board.PieceAt(column, y:2) as GamePiece!
        
        if countOfMatchingPieces([first, second, third], forPlayer: forPlayer) >= 2 {
            if first.IsOpen() { return first }
            if second.IsOpen(){ return second }
            if third.IsOpen() { return third }
        }
        
        return nil
    }
    
    func FreePieceInRow(row : Int, forPlayer : Player) -> GamePiece? {
        let first = Manager.Board.PieceAt(0, y: row) as GamePiece!
        let second = Manager.Board.PieceAt(1, y: row) as GamePiece!
        let third = Manager.Board.PieceAt(2, y: row) as GamePiece!
        
        if countOfMatchingPieces([first, second, third], forPlayer: forPlayer) >= 2 {
            if first.IsOpen() { return first }
            if second.IsOpen() { return second }
            if third.IsOpen() { return third }
        }
        
        return nil
    }
    
    func FreeDiagonalPiece(forPlayer : Player) -> GamePiece? {
        // Diagonal if the AI owns the middle piece
        if Manager.Board.PieceAt(1, y: 1).PlayerOwner == forPlayer{
            // Check top left and right, bottom left and right
            if Manager.Board.PieceAt(0, y: 0).PlayerOwner == forPlayer && Manager.Board.IsOpen(2, y: 2) {
                return Manager.Board.PieceAt(2, y : 2)
            }
            else if Manager.Board.PieceAt(2, y: 2).PlayerOwner == forPlayer && Manager.Board.IsOpen(0, y: 0) {
                return Manager.Board.PieceAt(0, y : 0)
            }
            else if Manager.Board.PieceAt(0, y: 2).PlayerOwner == forPlayer && Manager.Board.IsOpen(2, y: 0) {
                return Manager.Board.PieceAt(2, y : 0)
            }
            else if Manager.Board.PieceAt(2, y: 0).PlayerOwner == forPlayer && Manager.Board.IsOpen(0, y: 2) {
                return Manager.Board.PieceAt(0, y : 2)
            }
        }
        else if Manager.Board.PieceAt(1, y: 1).PlayerOwner == nil // Or the middle piece is open
            && ((Manager.Board.PieceAt(0, y: 2).PlayerOwner == forPlayer
                && Manager.Board.PieceAt(2, y: 0).PlayerOwner == forPlayer)
                || (Manager.Board.PieceAt(0, y: 0).PlayerOwner == forPlayer
                    && Manager.Board.PieceAt(2, y: 2).PlayerOwner == forPlayer)) {
            return Manager.Board.PieceAt(1, y: 1)
        }
        return nil
    }
    
    func countOfMatchingPieces(pieces : [GamePiece], forPlayer: Player) -> Int {
        var total = 0
        for piece in pieces {
            if piece.PlayerOwner == forPlayer { total++ }
        }
        return total
    }
}