//
//  TicTacToeGameManager.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/21/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation

public enum GameType: Int {
    case UnStarted = 0
    case SinglePlayer = 1
    case TwoPlayer = 2
}

public class GameManager: NSObject {
    public var board : GameBoard
    public var player1 : Player
    public var player2 : Player
    var currentGameType : GameType
    public var whoseTurnIsIt : Int
    var turnCount : Int
    var finished : Bool
    var viewController : TicTacToeViewController?
    var AI : GameAI?
    var currentPlayerForTurn: Player! {
        get {
            return whoseTurnIsIt == 1 ? player1 : player2
        }
    }
    
    public init(gameType: GameType, parentViewController: TicTacToeViewController?) {
        currentGameType = gameType
        viewController = parentViewController
        player1 = Player(playerName: "Player 1", cpu: false, pieceRepresentation: "X")
        player2 = Player(playerName: "Player 2", cpu: currentGameType == GameType.SinglePlayer, pieceRepresentation: "O")
        turnCount = 0
        finished = false
        board = GameBoard()
        whoseTurnIsIt = 1
        super.init()
        AI = GameAI(gameManager: self)
    }
    
    public func placedPiece(x : Int, y : Int) -> Bool {
        let piece = board.pieceAt(x, y: y)
        if piece.isOpen {
            if whoseTurnIsIt == 1 {
                piece?.playerOwner = player1
            }
            else {
                piece?.playerOwner = player2
            }
            viewController?.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: x, inSection: y)])
            nextTurn()
            return true
        }
        
        return false
    }
    
    public func nextTurn() {
        checkForWinner()
        if !finished {
            turnCount++
            whoseTurnIsIt = whoseTurnIsIt == 1 ? 2 : 1
            
            if whoseTurnIsIt == 2 && currentGameType == GameType.SinglePlayer {
                AI?.makeBestMove()
            }
        }
    }
    
    public func checkForWinner() {
        // Check all starting from top left
        // Do horizontal rows
        var hasWon : Bool = true
        for section : Int in 0...2 {
            let piece = board.pieceAt(0, y: section) as GamePiece!
            if let firstOwner = piece.playerOwner {
                hasWon = true
                for row in 1...2 {
                    hasWon = hasWon && (board.pieceAt(row, y: section) as GamePiece!).playerOwner? == firstOwner
                }
                if hasWon {
                    break
                }
            }
            else {
                hasWon = false
            }
        }
        
        if hasWon {
            endGameForWinner(currentPlayerForTurn)
        }
        
        // then diagonals
        let topLeft = board.pieceAt(0, y: 0)  as GamePiece!
        let topRight = board.pieceAt(2, y: 0) as GamePiece!
        let middle = board.pieceAt(1, y: 1) as GamePiece!
        let bottomRight =  board.pieceAt(2, y: 2) as GamePiece!
        let bottomLeft = board.pieceAt(0, y: 2) as GamePiece!
        if middle.playerOwner != nil
        {
            hasWon = topLeft.playerOwner == middle.playerOwner && middle.playerOwner == bottomRight.playerOwner
            if !hasWon {
                hasWon = bottomLeft.playerOwner == middle.playerOwner && middle.playerOwner == topRight.playerOwner
            }
        }
        
        if hasWon {
            endGameForWinner(currentPlayerForTurn)
        }
        
        // then vertical rows
        hasWon = true
        for row : Int in board.rows {
            let piece = board.pieceAt(row, y: 0) as GamePiece!
            if let firstOwner = piece.playerOwner {
                hasWon = true
                for section in 1...2 {
                    hasWon = hasWon && (board.pieceAt(row, y: section) as GamePiece!).playerOwner? == firstOwner
                }
                if hasWon {
                    break
                }
            }
            else {
                hasWon = false
            }
        }
        
        if hasWon {
            endGameForWinner(currentPlayerForTurn)
        }
        else if turnCount == 8 {
            endGameForWinner(nil)
        }
    }
    
    public func endGameForWinner(winner : Player?) {
        finished = true
        if let w = winner {
            viewController?.announceWinner("\(w.displayName) won! Play again?")
        }
        else
        {
            viewController?.announceWinner("Draw! Play again?")
        }
    }
}