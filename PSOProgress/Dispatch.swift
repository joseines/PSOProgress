//
//  Dispatch.swift
//  PSOProgress
//
//  Created by Jose Ines Cantu Arrambide on 8/24/16.
//  Copyright © 2016 Jose Ines Cantu Arrambide. All rights reserved.
//

import Foundation
public func psoDispatch_sync_to_main_queue(dispatch_block: () -> Void){
    if NSThread.isMainThread() {
        dispatch_block()
    }
    else{
        dispatch_sync(dispatch_get_main_queue(), dispatch_block)
    }
}