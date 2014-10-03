//
//  TicTacToeTests.swift
//  TicTacToeTests
//
//  Created by Bay Phillips on 9/8/14.
//  Copyright (c) 2014 Bay Phillips. All rights reserved.
//

import UIKit
import XCTest
import TicTacToe

class TicTacToeTests: XCTestCase {
    
    var manager: GameManager!
    
    override func setUp() {
        super.setUp()
        manager = GameManager(gameType: GameType.SinglePlayer, parentViewController: nil) as GameManager
    }
    
    override func tearDown() {
        manager = nil
        super.tearDown()
    }
    
    func testAIPlacedInMiddle()
    {
        manager.placedPiece(0, y: 0);
        XCTAssert(manager.board.pieceAt(1, y: 1).playerOwner == manager.player2, "AI didn't go to middle piece. Board: \(manager.board)")
    }
    
    func testAIPlacedInCorner()
    {
        manager.placedPiece(1, y: 1)
        XCTAssert(  !manager.board.isOpen(0, y: 0) ||
                    !manager.board.isOpen(2, y: 0) ||
                    !manager.board.isOpen(0, y: 2) ||
                    !manager.board.isOpen(2, y: 2), "AI didn't place in corner. Board: \(manager.board)")
    }
    
    func testAIBlockedFork()
    {
        manager.placedPiece(0, y: 1)
        manager.placedPiece(2, y: 1)
        XCTAssert(manager.board.pieceAt(1, y: 1).playerOwner == manager.player2
            && manager.board.pieceAt(1, y: 0).playerOwner == manager.player2, "AI didn't successfully block fork. Board: \(manager.board)")
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock() {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
