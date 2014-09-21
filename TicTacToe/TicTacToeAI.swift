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
    var dummyBoard : GameBoard
    
    init(gameManager : GameManager) {
        Manager = gameManager
        dummyBoard = Manager.Board.copy() as GameBoard
    }
    
    func MakeBestMove() {
//        var leftPieces = [GamePiece]()
//        var rightPieces = [GamePiece]()
//        var topPieces = [GamePiece]()
//        var bottomPieces = [GamePiece]()
//        
//        for x in [0,1] {
//            for y in Manager.Board.Rows {
//                leftPieces.append(Manager.Board.PieceAt(x, y: y))
//            }
//        }
//        
//        for x in [1,2] {
//            for y in Manager.Board.Rows {
//                rightPieces.append(Manager.Board.PieceAt(x, y: y))
//            }
//        }
//        
//        for x in Manager.Board.Columns {
//            for y in [0,1] {
//                topPieces.append(Manager.Board.PieceAt(x, y: y))
//            }
//        }
//        
//        for x in Manager.Board.Columns {
//            for y in [1,2] {
//                bottomPieces.append(Manager.Board.PieceAt(x, y: y))
//            }
//        }
//        
//        let numberInLeft = countOfMatchingPieces(leftPieces, forPlayer: Manager.Player1)
//        let numberInRight = countOfMatchingPieces(rightPieces, forPlayer: Manager.Player1)
//        let numberInTop = countOfMatchingPieces(topPieces, forPlayer: Manager.Player1)
//        let numberInBottom = countOfMatchingPieces(bottomPieces, forPlayer: Manager.Player1)
        
//        let leftRightPreference = numberInLeft == numberInRight
//            ? 0
//            : numberInLeft > numberInRight
//                ? 1
//                : 2
//        
//        let topBottomPreference = numberInTop == numberInBottom
//            ? 0
//            : numberInTop > numberInBottom
//                ? 1
//                : 2
        
        if Manager.TurnCount == 1 {
            if Manager.Board.PieceAt(1, y: 1).IsOpen() {
                Manager.PlacedPiece(1, y: 1)
            }
            else {
                Manager.PlacedPiece(0, y: 0)
            }
            return
        }
        
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
        
        // Can I make a fork
        let depth = 2
        let myFork = MinMax(depth, player: Manager.Player2, alpha: Int.min, beta: Int.max)
        NSLog("Fork: \(myFork.score)")
        if myFork.score > 0 {
            Manager.PlacedPiece(myFork.x, y: myFork.y)
            return
        }
        
        // Can I block a fork
        let blockFork = MinMax(depth, player: Manager.Player1, alpha: Int.min, beta: Int.max)
        NSLog("Block: \(blockFork.score)")
        if blockFork.score < 0 {
            Manager.PlacedPiece(blockFork.x, y: blockFork.y)
            return
        }
        
        // Place center if open
        if Manager.Board.PieceAt(1, y: 1).IsOpen() {
            Manager.PlacedPiece(1, y: 1)
            return
        }
        
        if let free = FreeCornerPiece() {
            Manager.PlacedPiece(free.X, y: free.Y)
            return
        }
        
        if let free = FreeMiddlePiece() {
            Manager.PlacedPiece(free.X, y: free.Y)
            return
        }
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
        if Manager.Board.PieceAt(1, y: 1).PlayerOwner == forPlayer {
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
        else if Manager.Board.PieceAt(1, y: 1).IsOpen() // Or the middle piece is open
            && ((Manager.Board.PieceAt(0, y: 2).PlayerOwner == forPlayer
                && Manager.Board.PieceAt(2, y: 0).PlayerOwner == forPlayer)
                || (Manager.Board.PieceAt(0, y: 0).PlayerOwner == forPlayer
                    && Manager.Board.PieceAt(2, y: 2).PlayerOwner == forPlayer)) {
            return Manager.Board.PieceAt(1, y: 1)
        }
        return nil
    }
    
    func FreeCornerPiece() -> GamePiece? {
        let topLeft = Manager.Board.PieceAt(0, y: 0)
        let bottomLeft = Manager.Board.PieceAt(0, y: 2)
        let topRight = Manager.Board.PieceAt(2, y: 0)
        let bottomRight = Manager.Board.PieceAt(2, y: 2)
        
        if topLeft.IsOpen() { return topLeft }
        if bottomLeft.IsOpen() { return bottomLeft }
        if topRight.IsOpen() { return topRight }
        if bottomLeft.IsOpen() { return bottomLeft }
        
        return nil
    }
    
    func FreeMiddlePiece() -> GamePiece? {
        let top = Manager.Board.PieceAt(1, y: 0)
        let bottom = Manager.Board.PieceAt(1, y: 2)
        let left = Manager.Board.PieceAt(0, y: 1)
        let right = Manager.Board.PieceAt(2, y: 0)
        
        if top.IsOpen() { return top }
        if bottom.IsOpen() { return bottom }
        if left.IsOpen() { return left }
        if right.IsOpen() { return right }
        
        return nil
    }
    
    func PlayersCornerPieces(player: Player) -> [GamePiece] {
        var pieces = [GamePiece]()
        for section in [0,2] {
            for row in [0,2] {
                if Manager.Board.PieceAt(row, y: section).PlayerOwner == player {
                    pieces.append(Manager.Board.PieceAt(row, y: section))
                }
            }
        }
        return pieces
    }
    
    func countOfMatchingPieces(pieces : [GamePiece], forPlayer: Player) -> Int {
        var total = 0
        for piece in pieces {
            if piece.PlayerOwner == forPlayer { total++ }
        }
        return total
    }
    
    /*
        Found this MinMaxing approach in java, adpating for Swift
        http://www.ntu.edu.sg/home/ehchua/programming/java/JavaGame_TicTacToe_AI.html
    */
    func MinMax(depth : Int, player : Player, alpha : Int, beta : Int) -> MMResult {
        
        var score : Int
        var bestX : Int = -1
        var bestY : Int = -1
        var currentAlpha = alpha
        var currentBeta = beta
        var emptyPieces = dummyBoard.EmptyPieces()
        
        if emptyPieces.count == 0 || depth == 0 {
            // Game over, cant do anything
            score = evaluateScore()
            return MMResult(x: bestX, y: bestY, score: score)
        }
        else {
            for piece in emptyPieces {
                piece.PlayerOwner = player
                if player == Manager.Player2 {
                    score = MinMax(depth - 1, player: Manager.Player1, alpha : alpha, beta : beta).score
                    if score > currentAlpha {
                        currentAlpha = score
                        bestX = piece.X
                        bestY = piece.Y
                    }
                }
                else {
                    score = MinMax(depth - 1, player: Manager.Player2, alpha : alpha, beta : beta).score
                    if score < currentBeta {
                        currentBeta = score
                        bestX = piece.X
                        bestY = piece.Y
                    }
                }
                
                piece.PlayerOwner = nil
                if currentAlpha >= currentBeta { break }
            }
        }
        
        return MMResult(x: bestX, y: bestY, score: player == Manager.Player2 ? alpha : beta)
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
        
        let firstPiece = Manager.Board.PieceAt(line.row1, y: line.col1)
        let secondPiece = Manager.Board.PieceAt(line.row2, y: line.col2)
        let thirdPiece = Manager.Board.PieceAt(line.row3, y: line.col3)
        
        score = firstPiece.PlayerOwner == Manager.Player2
            ? 1
            : firstPiece.PlayerOwner == Manager.Player1
                ? -1
                : 0
        
        if secondPiece.PlayerOwner == Manager.Player2 {
            if score == 1 {
                score = 10
            }
            else if score == -1 {
                return 0
            }
            else {
                score = 1
            }
        } else if secondPiece.PlayerOwner == Manager.Player1 {
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
        
        if thirdPiece.PlayerOwner == Manager.Player2 {
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
        else if thirdPiece.PlayerOwner == Manager.Player1 {
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

struct MMLine {
    var row1, col1, row2, col2, row3, col3 : Int
}

struct MMResult {
    var x : Int
    var y : Int
    var score : Int
}