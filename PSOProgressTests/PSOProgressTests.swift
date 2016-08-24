//
//  PSOProgressTests.swift
//  PSOProgressTests
//
//  Created by Jose Ines Cantu Arrambide on 8/23/16.
//  Copyright © 2016 Jose Ines Cantu Arrambide. All rights reserved.
//

import XCTest
@testable import PSOProgress

class PSOProgressTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    

    func testSimpleProgress() {
        let progress = PSOProgress()
        progress.totalUnitCount = 999
        
        for _ in 0 ..< 500{
            progress.completedUnitCount += 1
        }
        
        XCTAssert(progress.progress >= 0.5, "expected more than 0.5 have: \(progress.progress)")
        
        for _ in 0 ..< 500{
            progress.completedUnitCount += 1
        }
        
        XCTAssert(progress.progress == 1, "expected 1 have: \(progress.progress)")
    }
    
    func testOneLevelChildProgress(){
        let mainProgress = PSOProgress()
        
        let task1 = PSOProgress(totalUnitCount: 2)
        let task2 = PSOProgress(totalUnitCount: 10)
        
        mainProgress.add(childProgress: task1, withTotalPendingCount: 1)
        mainProgress.add(childProgress: task2, withTotalPendingCount: 1)
        
        task1.completedUnitCount = 2
        
        XCTAssert(mainProgress.progress == 0.5, "expected progress of 0.5, found: \(mainProgress.progress)")
        
        task2.completedUnitCount = 10
        XCTAssert(mainProgress.progress == 1, "expected progress of 1, found: \(mainProgress.progress)")
        
    }
    
    func testTwoLevelChildProgress(){
        let syncProgress = PSOProgress(name: "SyncProgress")
        
        let download = syncProgress.add(childProgress: PSOProgress(name: "download"), withTotalPendingCount: 1)
        let upload = syncProgress.add(childProgress: PSOProgress(name: "upload"), withTotalPendingCount: 1)
        
        download.totalUnitCount = 100
        download.completedUnitCount = 100
        
        XCTAssert(syncProgress.progress == 0.5, "expected 0.5 found: \(syncProgress.progress)")
        
        let fetchModifiedRecords = upload.add(childProgress: PSOProgress(name: "fetchRecords"), withTotalPendingCount: 1)
        let uploadRecords = upload.add(childProgress: PSOProgress(name: "upload records"), withTotalPendingCount: 9)
        
        fetchModifiedRecords.totalUnitCount = 10
        fetchModifiedRecords.completedUnitCount = 10
        
        XCTAssert(upload.progress == 0.1, "expected 0.1 found: \(upload.progress)")
        XCTAssert(syncProgress.progress == 0.55, "expected 0.55 found: \(syncProgress.progress)")
        
        uploadRecords.totalUnitCount = 100
        uploadRecords.completedUnitCount = 50
        
        XCTAssert(upload.progress == 0.55, "expected 0.55 found:\(upload.progress)")
        XCTAssert(syncProgress.progress == 0.775, "expected 0.775 found: \(syncProgress.progress)")
        
        uploadRecords.completedUnitCount = 100
        
        XCTAssert(upload.progress == 1, "expected 1 found:\(upload.progress)")
        XCTAssert(syncProgress.progress == 1, "expected 1 found: \(syncProgress.progress)")
    }
    
    func testWeightedChildProgress(){
        let mainProgress = PSOProgress()
        
        let task1 = PSOProgress(totalUnitCount: 2)
        let task2 = PSOProgress(totalUnitCount: 10)
        
        mainProgress.add(childProgress: task1, withTotalPendingCount: 1)
        mainProgress.add(childProgress: task2, withTotalPendingCount: 9)
        
        task1.completedUnitCount = 2
        
        XCTAssert(mainProgress.progress == 0.1, "expected progress of 0.5, found: \(mainProgress.progress)")
        
        task2.completedUnitCount = 10
        XCTAssert(mainProgress.progress == 1, "expected progress of 1, found: \(mainProgress.progress)")
    }
    
    func testUnacceptedValues(){
        let progress = PSOProgress()
        progress.completedUnitCount = -1
        XCTAssert(progress.completedUnitCount == 0, "expected zero found: \(progress.completedUnitCount)")
        
        progress.totalUnitCount = -1
        XCTAssert(progress.totalUnitCount! == 0, "expected zero found: \(progress.completedUnitCount)")
        
        progress.totalUnitCount = 0
        progress.completedUnitCount = 100
        XCTAssert(progress.progress == 0, "expected zero progress, found :\(progress.progress)")
        
        progress.totalUnitCount = nil
        progress.completedUnitCount = 100
        XCTAssert(progress.progress == 0, "expected zero progress, found :\(progress.progress)")
        
    }
    
    func testUnacceptedChildValues(){
        let mainProgress = PSOProgress()
        
        let task1 = PSOProgress(totalUnitCount: 2)
        let task2 = PSOProgress(totalUnitCount: 10)
        
        mainProgress.add(childProgress: task1, withTotalPendingCount: -1)
        mainProgress.add(childProgress: task2, withTotalPendingCount: 9)
        
        task1.completedUnitCount = 2
        
        XCTAssert(mainProgress.progress == 0, "expected progress of 0, found: \(mainProgress.progress)")
        
        task2.completedUnitCount = 10
        XCTAssert(mainProgress.progress == 1, "expected progress of 1, found: \(mainProgress.progress)")
    }
    
    func testZeroValuesPendingCount(){
        let mainProgress = PSOProgress()
        
        let task1 = PSOProgress(totalUnitCount: 0)
        let task2 = PSOProgress(totalUnitCount: 0)
        
        mainProgress.add(childProgress: task1, withTotalPendingCount: 0)
        mainProgress.add(childProgress: task2, withTotalPendingCount: 0)
        
        task1.completedUnitCount = 2
        
        XCTAssert(mainProgress.progress == 0, "expected progress of 0, found: \(mainProgress.progress)")
        
        task2.completedUnitCount = 10
        XCTAssert(mainProgress.progress == 0, "expected progress of 0, found: \(mainProgress.progress)")
    }
    
    func testAddingUsedChildProgressToAnother(){
        let mainProgress = PSOProgress()
        
        let task1 = PSOProgress(totalUnitCount: 2)
        let task2 = PSOProgress(totalUnitCount: 10)
        
        mainProgress.add(childProgress: task1, withTotalPendingCount: 100)
        mainProgress.add(childProgress: task2, withTotalPendingCount: 900)
        
        task1.completedUnitCount = 2
        
        XCTAssert(mainProgress.progress == 0.1, "expected progress of .1, found: \(mainProgress.progress)")
        
        task2.completedUnitCount = 10
        XCTAssert(mainProgress.progress == 1, "expected progress of 1, found: \(mainProgress.progress)")
        
        let mainProgress2 = PSOProgress()
        mainProgress2.add(childProgress: task1, withTotalPendingCount: 10)
        XCTAssert(mainProgress2.childs.count == 0, "expected zero childs")
    }
    
    
    func testProgressNotification(){
        let mainProgress = PSOProgress(totalUnitCount: Int(arc4random_uniform(100000)))
        
        var notificationCount = 0;
        NSNotificationCenter.defaultCenter().addObserverForName(PSOProgress.PSOPROGRESS_CHANGED_NOTIFICATION, object: mainProgress, queue: nil) { (notif) in
            notificationCount += 1
            if(mainProgress.progress == 1){
                XCTAssert(notificationCount <= 100, "expected less than or equal to 100 notifications, found: \(notificationCount)")
            }
            
            print("RECEIVED NOTIFICATION Current Progress: \(mainProgress.progress)")
        }
        
        for _ in 0 ..< mainProgress.totalUnitCount!{
            mainProgress.completedUnitCount += 1
        }

    }
    
}
