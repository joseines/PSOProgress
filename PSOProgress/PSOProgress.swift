//
//  PSOProgress.swift
//  PSOProgress
//
//  Created by Jose Ines Cantu Arrambide on 8/23/16.
//  Copyright © 2016 Jose Ines Cantu Arrambide. All rights reserved.
//

//

import Foundation


public func ==(lhs: PSOProgress, rhs: PSOProgress) -> Bool{
    return lhs.identifier == rhs.identifier
}

public class PSOProgress: Hashable, CustomStringConvertible, CustomDebugStringConvertible{
    
    public static let PSOPROGRESS_CHANGED_NOTIFICATION = "PSOProgress_Changed"
    
    private lazy var bundle: NSBundle = {
        return NSBundle(forClass: self.dynamicType)
    }()
    
    var localizedDescription: String{
        let unit = localizedUnitName ?? "unit(s)"
        
        let localizedString = NSLocalizedString("LCompleted %li %@ of %li", tableName: "PSOProgress", bundle: self.bundle, value: "", comment: "")
        
        if let totalUnitCount = self.totalUnitCount{
            return String(format: localizedString, completedUnitCount, unit, totalUnitCount)
        }
        else{
            return String(format: localizedString, completedUnitCount)            
        }
    }
    
    // Localized Unit for the localized Description
    var localizedUnitName: String?
    
    
    // unique identifier
    private(set) var identifier = NSUUID().UUIDString
    
    var name: String?
    weak var parent: PSOProgress?
    
    // MARK: Initialization
    convenience init(){
        self.init(name: nil, totalUnitCount: nil)
    }
    
    convenience init(name: String?){
        self.init(name: name, totalUnitCount: nil)
    }
    
    init(name: String? = nil, totalUnitCount: Int?){
        self.totalUnitCount = totalUnitCount
    }
    
    // MARK: Childs
    private(set) var childs = [PSOProgress: Int]()
    func add(childProgress progress: PSOProgress, withTotalPendingCount count: Int) -> PSOProgress{
        guard progress.parent == nil else{
            print("WARNING: Progress was not added becuase it already had a parent: \(progress)")
            return progress
        }
        
        progress.parent = self
        childs[progress] = max(0,count)
        
        return progress
    }
    
    //MARK: Total & Completed Unit Count
    
    // number of units to complete
    var totalUnitCount: Int?{
        didSet{
            guard totalUnitCount >= 0 else{
                totalUnitCount = 0
                return
            }
            
            compute()
        }
    }
    
    // Number of completed units
    var completedUnitCount: Int = 0{
        didSet{
            guard completedUnitCount >= 0 else{
                completedUnitCount = 0
                return
            }
            
            compute()
        }
    }
    
    private var lastProgressNotification: Double = 0
    
    //Progress express in decimal between 0 and 1
    private(set) var progress: Double = 0{
        didSet{
            guard progress >= 0 else{
                progress = 0
                return
            }
            
            guard progress <= 1 else{
                progress = 1
                return
            }
            
            
            
            if (abs(lastProgressNotification - progress) >= 0.01 || progress == 1 || progress == 0){
                lastProgressNotification = progress
                
                psoDispatch_sync_to_main_queue {
                    NSNotificationCenter.defaultCenter().postNotificationName(PSOProgress.PSOPROGRESS_CHANGED_NOTIFICATION, object: self)
                }
            }
            
            if let parent = self.parent{
                parent.childrenDidChange(self)
            }
        }
    }
    
    // MARK: Children Notification
    private func childrenDidChange(sender: PSOProgress){
        compute()
    }
    

    // MARK: Computation
    private func compute(){
        
        if childs.count > 0 {
            let totalChildPendingCount = childs.reduce(0, combine: { (currentTotal , child) -> Int in
                return currentTotal + child.1
            })
            
            var progressSum = 0.0
            for (progress, childPendingCount) in childs{
                progressSum += (Double(childPendingCount) / Double(totalChildPendingCount)) * progress.progress
            }
            
            progress = progressSum
            
        }
        else if let totalUnitCount = self.totalUnitCount{
            let completedUnitCount = self.completedUnitCount ?? 0
            
            if totalUnitCount == 0{
                progress = 0
            }
            else{
                progress =  min(Double(completedUnitCount) / Double(totalUnitCount), 1)
            }
        }
    }
    
    //MARK: Hashable Protocol
    public var hashValue: Int{
        return identifier.hash
    }
    
    //MARK: Custom String Convertible
    public var description: String{
        return "Progress Name:\(name ?? identifier) Progress Value:\(self.progress)"
    }
    
    //MARK: Custom Debug Description Protocol
    public var debugDescription: String{
        return self.description
    }
    
}