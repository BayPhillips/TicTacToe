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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.edgesForExtendedLayout = UIRectEdge.None
        self.title = "TicTacToe"
        self.view.backgroundColor = UIColor.whiteColor()
        
        var flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        collectionView = UICollectionView(frame: CGRect(origin: CGPointMake(0, 50), size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height - 100)), collectionViewLayout: flowLayout)
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.blackColor()
        collectionView.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        collectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)

        self.view.addSubview(collectionView)
    }

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView!) -> Int {
        return 3
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - 10) / 3, height: (collectionView.bounds.size.height - 10) / 3)
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as UICollectionViewCell
        cell.backgroundColor = UIColor.whiteColor()
        var label = UILabel(frame: cell.bounds)
        label.text = "\(indexPath.section) and \(indexPath.row)"
        cell.contentView.addSubview(label)
        return cell
    }
}

enum GameType: Int {
    case SinglePlayer = 1
    case TwoPlayer = 2
}

class GameManager: NSObject {

    var GameBoard : Dictionary<NSIndexPath, GamePiece>
    var Player1 : Player
    var Player2 : Player
    var CurrentGameType : GameType
    
    init(gameType: GameType) {
        CurrentGameType = gameType
        Player1 = Player(name: "X", isCPU: false)
        Player2 = Player(name: "O", isCPU: CurrentGameType == GameType.SinglePlayer)
        
        GameBoard = Dictionary<NSIndexPath, GamePiece>()
        for section in 0...3 {
            for row in 0...3 {
                GameBoard[NSIndexPath(forRow: row, inSection: section)] = GamePiece()
            }
        }
        
        super.init()
    }
}

class Player : NSObject {
    var Name : NSString
    var IsCPU : Bool
    
    init(name: NSString, isCPU: Bool) {
        Name = name
        IsCPU = isCPU
    }
}

class GamePiece :NSObject {
    var PlayerOwner : Player!
    override init() {
        super.init()
    }
}