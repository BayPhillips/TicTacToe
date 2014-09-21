//
//  TicTacToeGameManager.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/21/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import Foundation


enum GameType: Int {
    case UnStarted = 0
    case SinglePlayer = 1
    case TwoPlayer = 2
}

class GameManager: NSObject {
    
    var Board : GameBoard
    var Player1 : Player
    var Player2 : Player
    var CurrentGameType : GameType
    var WhoseTurnIsIt : Int
    var TurnCount : Int
    var Finished : Bool
    var ViewController : TicTacToeViewController
    var AI : TicTacToeAI?
    
    init(gameType: GameType, viewController: TicTacToeViewController) {
        CurrentGameType = gameType
        ViewController = viewController
        Player1 = Player(name: "Player 1", isCPU: false)
        Player2 = Player(name: "Player 2", isCPU: CurrentGameType == GameType.SinglePlayer)
        TurnCount = 0
        Finished = false
        Board = GameBoard()
        WhoseTurnIsIt = 1
        super.init()
        AI = TicTacToeAI(gameManager: self)
    }
    
    func CurrentPlayerForTurn() -> Player! {
        return WhoseTurnIsIt == 1 ? Player1 : Player2
    }
    
    func PlacedPiece(x : Int, y : Int) -> Bool {
        let piece = Board.PieceAt(x, y: y)
        if piece.IsOpen() {
            if self.WhoseTurnIsIt == 1 {
                piece?.PlayerOwner = self.Player1
            }
            else {
                piece?.PlayerOwner = self.Player2
            }
            ViewController.collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: x, inSection: y)])
            self.NextTurn()
            return true
        }
        
        return false
    }
    
    func NextTurn() {
        self.CheckForWinner()
        if !Finished {
            TurnCount++
            WhoseTurnIsIt = WhoseTurnIsIt == 1 ? 2 : 1
            
            if WhoseTurnIsIt == 2 && CurrentGameType == GameType.SinglePlayer {
                AI?.MakeBestMove()
            }
        }
    }
    
    func CheckForWinner() {
        // Check all starting from top left
        // Do horizontal rows
        var hasWon : Bool = true
        for section : Int in 0...2 {
            let piece = Board.PieceAt(0, y: section) as GamePiece!
            if let firstOwner = piece.PlayerOwner {
                hasWon = true
                for row in 1...2 {
                    hasWon = hasWon && (Board.PieceAt(row, y: section) as GamePiece!).PlayerOwner? == firstOwner
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
            self.EndGameForWinner(self.CurrentPlayerForTurn())
        }
        
        // then diagonals
        let topLeft = Board.PieceAt(0, y: 0)  as GamePiece!
        let topRight = Board.PieceAt(2, y: 0) as GamePiece!
        let middle = Board.PieceAt(1, y: 1) as GamePiece!
        let bottomRight =  Board.PieceAt(2, y: 2) as GamePiece!
        let bottomLeft = Board.PieceAt(0, y: 2) as GamePiece!
        if middle.PlayerOwner != nil
        {
            hasWon = topLeft.PlayerOwner == middle.PlayerOwner && middle.PlayerOwner == bottomRight.PlayerOwner
            if !hasWon {
                hasWon = bottomLeft.PlayerOwner == middle.PlayerOwner && middle.PlayerOwner == topRight.PlayerOwner
            }
        }
        
        if hasWon {
            self.EndGameForWinner(self.CurrentPlayerForTurn())
        }
        
        // then vertical rows
        hasWon = true
        for row : Int in Board.Rows {
            let piece = Board.PieceAt(row, y: 0) as GamePiece!
            if let firstOwner = piece.PlayerOwner {
                hasWon = true
                for section in 1...2 {
                    hasWon = hasWon && (Board.PieceAt(row, y: section) as GamePiece!).PlayerOwner? == firstOwner
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
            self.EndGameForWinner(self.CurrentPlayerForTurn())
        }
        else if self.TurnCount == 8 {
            self.EndGameForWinner(nil)
        }
    }
    
    func EndGameForWinner(winner : Player?) {
        Finished = true
        if let w = winner {
            self.ViewController.announceWinner("\(w.DisplayName()) won! Play again?")
        }
        else
        {
            self.ViewController.announceWinner("Draw! Play again?")
        }
    }
}

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