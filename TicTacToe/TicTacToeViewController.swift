//
//  ViewController.swift
//  TicTacToe
//
//  Created by Bay Phillips on 9/8/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import UIKit

class TicTacToeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView : UICollectionView!
    var Manager : GameManager!
    var playersLabel : UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge.None
        self.title = "TicTacToe"
        self.view.backgroundColor = UIColor.whiteColor()
        
        Manager = GameManager(gameType: GameType.UnStarted, viewController: self)
        
        playersLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.bounds.size.width, height: 100)))
        playersLabel.backgroundColor = UIColor.whiteColor()
        playersLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(playersLabel)
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        collectionView = UICollectionView(frame: CGRect(origin: CGPointMake(0, 100), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - 100)), collectionViewLayout: flowLayout)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        collectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        collectionView.hidden = true
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Single Player", style: UIBarButtonItemStyle.Plain, target: self, action: "startSinglePlayer")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Two Player", style: UIBarButtonItemStyle.Plain, target: self, action: "startTwoPlayer")
        
        self.view.addSubview(collectionView)
    }
    
    func startSinglePlayer() {
        Manager = GameManager(gameType: GameType.SinglePlayer, viewController: self)
        self.setPlayersLabel()
        collectionView.hidden = false
        collectionView.reloadData()
    }
    
    func startTwoPlayer() {
        Manager = GameManager(gameType: GameType.TwoPlayer, viewController: self)
        self.setPlayersLabel()
        collectionView.hidden = false
        collectionView.reloadData()
    }
    
    func reset() {
        Manager = GameManager(gameType: GameType.UnStarted, viewController: self)
        self.playersLabel.text = ""
        collectionView.hidden = true
        collectionView.reloadData()
    }
    
    func announceWinner(message: String) {
        let alertController = UIAlertController(title: "Game Over", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Single Player", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.startSinglePlayer()
            alertController.dismissViewControllerAnimated(true, completion:nil)
        }))
        alertController.addAction(UIAlertAction(title: "Two Player", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.startTwoPlayer()
            alertController.dismissViewControllerAnimated(true, completion:nil)
        }))
        alertController.addAction(UIAlertAction(title: "End", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.reset()
            alertController.dismissViewControllerAnimated(true, completion:nil)
        }))
        self.presentViewController(alertController, animated: true) { () -> Void in
            // do something
        }
    }
    
    func setPlayersLabel() {
        var text = "\(Manager.Player1.DisplayName()) vs. \(Manager.Player2.DisplayName())"
        if Manager.CurrentPlayerForTurn() == Manager.Player1 {
            text = "-> \(text)"
        }
        else {
            text = "\(text) <-"
        }
        playersLabel.text = text
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 10) / 3, height: (collectionView.bounds.size.height - 10) / 3)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        
        let piece = Manager.Board.PieceAt(indexPath.row, y: indexPath.section)
        if(piece?.PlayerOwner != nil) {
            var label = UILabel(frame: cell.bounds)
            label.text = piece?.PlayerOwner == Manager.Player1 ? "X" : "O"
            label.font = UIFont.systemFontOfSize(30)
            label.textAlignment = NSTextAlignment.Center
            cell.contentView.addSubview(label)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if Manager.PlacedPiece(indexPath.row, y: indexPath.section) {
            self.setPlayersLabel()
        }
    }
}

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
    var ViewController : TicTacToeViewController
    var AI : TicTacToeAI?
    
    init(gameType: GameType, viewController: TicTacToeViewController) {
        CurrentGameType = gameType
        ViewController = viewController
        Player1 = Player(name: "Player 1", isCPU: false)
        Player2 = Player(name: "Player 2", isCPU: CurrentGameType == GameType.SinglePlayer)
        TurnCount = 0
        
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
        if piece?.PlayerOwner == nil {
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
        TurnCount++
        WhoseTurnIsIt = WhoseTurnIsIt == 1 ? 2 : 1
        if WhoseTurnIsIt == 2 && CurrentGameType == GameType.SinglePlayer {
            AI?.MakeBestMove()
        }
        else {
            // Do we need to do anything here?
        }
    }
    
    func PlayAITurn() {
        
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
        for row : Int in 0...2 {
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
        if let w = winner {
            self.ViewController.announceWinner("\(w.DisplayName()) won! Play again?")
        }
        else
        {
            self.ViewController.announceWinner("Draw! Play again?")
        }
    }
}

class GameBoard : NSObject {
    var _data : Dictionary<NSIndexPath, GamePiece>
    
    override init() {
        _data = Dictionary<NSIndexPath, GamePiece>()
        for section in 0...2 {
            for row in 0...2 {
                _data[NSIndexPath(forRow: row, inSection: section)] = GamePiece(x: section, y: row)
            }
        }
        super.init()
    }
    
    func PieceAt(x : Int, y : Int) -> GamePiece! {
        return _data[NSIndexPath(forRow: y, inSection: x)] as GamePiece!
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
        let cpuString = IsCPU ? "(CPU)" : ""
        return "\(Name) \(cpuString)"
    }
}

class GamePiece :NSObject {
    var PlayerOwner : Player?
    var X : Int
    var Y : Int
    
    init(x: Int, y : Int) {
        X = x
        Y = y
        super.init()
    }
}