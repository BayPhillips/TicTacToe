//
//  TicTacToeAI.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/19/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation

private struct MMLine {
    var row1, col1, row2, col2, row3, col3 : Int
}

public struct MMResult {
    var x : Int
    var y : Int
    var score : Int
}

public class GameAI {
    var manager : GameManager
    var dummyBoard : GameBoard
    
    init(gameManager : GameManager) {
        manager = gameManager
        dummyBoard = manager.board.copy() as GameBoard
    }
    
    func makeBestMove() {
        // Try to place it in the middle if it's the first turn
        if manager.turnCount == 1 {
            if manager.board.pieceAt(1, y: 1).isOpen {
                manager.placedPiece(1, y: 1)
            }
            else {
                manager.placedPiece(0, y: 0)
            }
            return
        }
        
        // Check if I have two in a row anywhere and if so place it there
        // Vertical
        for column in manager.board.columns {
            if let freePiece = freePieceInColumn(column, forPlayer: manager.player2) {
                manager.placedPiece(freePiece.x, y : freePiece.y)
                return
            }
        }
        
        // Horizontal
        for row in manager.board.rows {
            if let freePiece = freePieceInRow(row, forPlayer: manager.player2) {
                manager.placedPiece(freePiece.x, y : freePiece.y)
                return
            }
        }
        
        // Diagonal
        if let piece = freeDiagonalPiece(manager.player2) {
            manager.placedPiece(piece.x, y: piece.y)
            return
        }

        // Check if the opposing player has two in a row anywhere and if so place it there to Block
        // Vertical
        for column in manager.board.columns {
            if let freePiece = freePieceInColumn(column, forPlayer: manager.player1) {
                manager.placedPiece(freePiece.x, y : freePiece.y)
                return
            }
        }
        
        // Horizontal
        for row in manager.board.rows {
            if let freePiece = freePieceInRow(row, forPlayer: manager.player1) {
                manager.placedPiece(freePiece.x, y : freePiece.y)
                return
            }
        }
        
        // Diagonal
        if let piece = freeDiagonalPiece(manager.player1) {
            manager.placedPiece(piece.x, y: piece.y)
            return
        }
        
        // Can I block a fork
        let depth = 2
        let blockFork = minMax(depth, player: manager.player2, alpha: Int.min, beta: Int.max)
        if blockFork.score < 0 {
            manager.placedPiece(blockFork.x, y: blockFork.y)
            return
        }
        
        // Place center if open
        if manager.board.pieceAt(1, y: 1).isOpen {
            manager.placedPiece(1, y: 1)
            return
        }
        
        // Place in a corner if free
        if let free = freeCornerPiece() {
            manager.placedPiece(free.x, y: free.y)
            return
        }
        
        // Place it somewhere already!
        if let free = freeMiddlePiece() {
            manager.placedPiece(free.x, y: free.y)
            return
        }
    }
    
    func freePieceInColumn(column : Int, forPlayer : Player) -> GamePiece? {
        let first = manager.board.pieceAt(column, y:0) as GamePiece!
        let second = manager.board.pieceAt(column, y:1) as GamePiece!
        let third = manager.board.pieceAt(column, y:2) as GamePiece!
        
        if countOfMatchingPieces([first, second, third], forPlayer: forPlayer) >= 2 {
            if first.isOpen { return first }
            if second.isOpen { return second }
            if third.isOpen { return third }
        }
        
        return nil
    }
    
    func freePieceInRow(row : Int, forPlayer : Player) -> GamePiece? {
        let first = manager.board.pieceAt(0, y: row) as GamePiece!
        let second = manager.board.pieceAt(1, y: row) as GamePiece!
        let third = manager.board.pieceAt(2, y: row) as GamePiece!
        
        if countOfMatchingPieces([first, second, third], forPlayer: forPlayer) >= 2 {
            if first.isOpen { return first }
            if second.isOpen { return second }
            if third.isOpen { return third }
        }
        
        return nil
    }
    
    func freeDiagonalPiece(forPlayer : Player) -> GamePiece? {
        // Diagonal if the AI owns the middle piece
        if manager.board.pieceAt(1, y: 1).playerOwner == forPlayer {
            // Check top left and right, bottom left and right
            if manager.board.pieceAt(0, y: 0).playerOwner == forPlayer
                && manager.board.isOpen(2, y: 2) {
                return manager.board.pieceAt(2, y : 2)
            }
            else if manager.board.pieceAt(2, y: 2).playerOwner == forPlayer
                && manager.board.isOpen(0, y: 0) {
                return manager.board.pieceAt(0, y : 0)
            }
            else if manager.board.pieceAt(0, y: 2).playerOwner == forPlayer
                && manager.board.isOpen(2, y: 0) {
                return manager.board.pieceAt(2, y : 0)
            }
            else if manager.board.pieceAt(2, y: 0).playerOwner == forPlayer
                && manager.board.isOpen(0, y: 2) {
                return manager.board.pieceAt(0, y : 2)
            }
        }
        else if manager.board.isOpen(1, y: 1) // Or the middle piece is open
            && ((manager.board.pieceAt(0, y: 2).playerOwner == forPlayer
                && manager.board.pieceAt(2, y: 0).playerOwner == forPlayer)
                || (manager.board.pieceAt(0, y: 0).playerOwner == forPlayer
                    && manager.board.pieceAt(2, y: 2).playerOwner == forPlayer)) {
            return manager.board.pieceAt(1, y: 1)
        }
        return nil
    }
    
    func freeCornerPiece() -> GamePiece? {
        let topLeft = manager.board.pieceAt(0, y: 0)
        let bottomLeft = manager.board.pieceAt(0, y: 2)
        let topRight = manager.board.pieceAt(2, y: 0)
        let bottomRight = manager.board.pieceAt(2, y: 2)
        
        if topLeft.isOpen { return topLeft }
        if bottomLeft.isOpen { return bottomLeft }
        if topRight.isOpen { return topRight }
        if bottomLeft.isOpen { return bottomLeft }
        
        return nil
    }
    
    func freeMiddlePiece() -> GamePiece? {
        let top = manager.board.pieceAt(1, y: 0)
        let bottom = manager.board.pieceAt(1, y: 2)
        let left = manager.board.pieceAt(0, y: 1)
        let right = manager.board.pieceAt(2, y: 0)
        
        if top.isOpen { return top }
        if bottom.isOpen { return bottom }
        if left.isOpen { return left }
        if right.isOpen { return right }
        
        return nil
    }
    
    func playersCornerPieces(player: Player) -> [GamePiece] {
        var pieces = [GamePiece]()
        for section in [0,2] {
            for row in [0,2] {
                let piece = manager.board.pieceAt(row, y:section)
                if piece.playerOwner == player {
                    pieces.append(piece)
                }
            }
        }
        return pieces
    }
    
    func countOfMatchingPieces(pieces : [GamePiece], forPlayer: Player) -> Int {
        var total = 0
        for piece in pieces {
            if piece.playerOwner == forPlayer { total++ }
        }
        return total
    }
    
    /*
        Found this MinMaxing approach in java, adpating for Swift
        http://www.ntu.edu.sg/home/ehchua/programming/java/JavaGame_TicTacToe_AI.html
    */
    func minMax(depth : Int, player : Player, alpha : Int, beta : Int) -> MMResult {
        var score : Int
        var bestX : Int = -1
        var bestY : Int = -1
        var currentAlpha = alpha
        var currentBeta = beta
        var emptyPieces = dummyBoard.emptyPieces
        
        if emptyPieces.count == 0 || depth == 0 {
            // Game over (shouldn't get here), or done with check
            score = evaluateScore()
            return MMResult(x: bestX, y: bestY, score: score)
        }
        else {
            for piece in emptyPieces {
                piece.playerOwner = player
                if player == manager.player2 {
                    score = minMax(depth - 1, player: manager.player1, alpha : alpha, beta : beta).score
                    if score > currentAlpha {
                        currentAlpha = score
                        bestX = piece.x
                        bestY = piece.y
                    }
                }
                else {
                    score = minMax(depth - 1, player: manager.player2, alpha : alpha, beta : beta).score
                    if score < currentBeta {
                        currentBeta = score
                        bestX = piece.x
                        bestY = piece.y
                    }
                }
                
                piece.playerOwner = nil
                if currentAlpha >= currentBeta { break }
            }
        }
        
        return MMResult(x: bestX, y: bestY, score: player == manager.player2 ? currentAlpha : currentBeta)
    }
    
    private func evaluateScore() -> Int {
        var score : Int = 0
        score += evaluateLine(MMLine(row1: 0, col1: 0, row2: 0, col2: 1, row3: 0, col3: 2))
        score += evaluateLine(MMLine(row1: 1, col1: 0, row2: 1, col2: 1, row3: 1, col3: 2))
        score += evaluateLine(MMLine(row1: 2, col1: 0, row2: 2, col2: 1, row3: 2, col3: 2))
        score += evaluateLine(MMLine(row1: 0, col1: 0, row2: 1, col2: 0, row3: 2, col3: 0))
        score += evaluateLine(MMLine(row1: 0, col1: 1, row2: 1, col2: 1, row3: 2, col3: 1))
        score += evaluateLine(MMLine(row1: 0, col1: 2, row2: 1, col2: 2, row3: 2, col3: 2))
        score += evaluateLine(MMLine(row1: 0, col1: 0, row2: 1, col2: 1, row3: 2, col3: 2))
        score += evaluateLine(MMLine(row1: 0, col1: 2, row2: 1, col2: 1, row3: 2, col3: 0))
        return score
    }
    
    private func evaluateLine(line : MMLine) -> Int {
        var score : Int = 0
        
        let firstPiece = manager.board.pieceAt(line.row1, y: line.col1)
        let secondPiece = manager.board.pieceAt(line.row2, y: line.col2)
        let thirdPiece = manager.board.pieceAt(line.row3, y: line.col3)
        
        score = firstPiece.playerOwner == manager.player2
            ? 1
            : firstPiece.playerOwner == manager.player1
                ? -1
                : 0
        
        if secondPiece.playerOwner == manager.player2 {
            if score == 1 {
                score = 10
            }
            else if score == -1 {
                return 0
            }
            else {
                score = 1
            }
        } else if secondPiece.playerOwner == manager.player1 {
            if score == -1 {
                score = -10
            }
            else if score == 1 {
                return 0
            }
            else {
                score = -1
            }
        }
        
        if thirdPiece.playerOwner == manager.player2 {
            if score > 0 {
                score *= 10
            }
            else if score < 0 {
                return 0
            }
            else {
                score = 1
            }
        }
        else if thirdPiece.playerOwner == manager.player1 {
            if score < 0 {
                score *= 10
            }
            else if score > 1 {
                return 0
            }
            else {
                return -1
            }
        }
        
        return score
    }
}