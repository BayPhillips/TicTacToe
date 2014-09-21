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
    var hasLoaded : Bool = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(!hasLoaded) {
            self.edgesForExtendedLayout = UIRectEdge.None
            self.title = "TicTacToe"
            self.view.backgroundColor = UIColor.whiteColor()
            
            playersLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: self.view.bounds.size.width, height: 100)))
            playersLabel.backgroundColor = UIColor.whiteColor()
            playersLabel.textAlignment = NSTextAlignment.Center
            playersLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            playersLabel.text = "Select a game mode to start"
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
            collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
            collectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
            collectionView.hidden = true
            
            // Gets the game in into its initial state
            self.reset()
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Single Player", style: UIBarButtonItemStyle.Plain, target: self, action: "startSinglePlayer")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Two Player", style: UIBarButtonItemStyle.Plain, target: self, action: "startTwoPlayer")
            
            self.view.addSubview(collectionView)
            
            hasLoaded = true
        }
    }
    
    func startSinglePlayer() {
        self.startGameWithType(GameType.SinglePlayer)
    }
    
    func startTwoPlayer() {
        self.startGameWithType(GameType.TwoPlayer)
    }
    
    func reset() {
        self.startGameWithType(GameType.UnStarted)
        collectionView.hidden = true
    }
    
    func startGameWithType(gameType: GameType) {
        Manager = GameManager(gameType: gameType, viewController: self)
        self.setPlayersLabel()
        collectionView.hidden = false
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
        var text : String = String()
        if Manager.CurrentGameType == GameType.UnStarted {
            text = "Select a game mode to start"
        }
        else {
            text = "\(Manager.Player1.DisplayName()) vs. \(Manager.Player2.DisplayName())"
            if Manager.CurrentPlayerForTurn() == Manager.Player1 {
                text = "-> \(text)"
            }
            else {
                text = "\(text) <-"
            }
        }
        
        playersLabel.text = text
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Manager.Board.Columns.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return Manager.Board.Rows.count
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