//
//  CoreDataHelper.swift
//  uCopy
//
//  Created by 周辉 on 2022/11/23.
//

import Foundation
import CoreData

class CoreDataHelper {
    static func historyFetchRequestWithLimit(size: Int) -> NSFetchRequest<History> {
        let r: NSFetchRequest<History> = History.fetchRequest()
        r.sortDescriptors = [
            NSSortDescriptor(keyPath: \History.createDate, ascending: false)
        ]
        if size > 0 {        
            r.fetchLimit = size
        }
        return r
    }
    static func snippetFetchRequest() -> NSFetchRequest<Snippet> {
        let r: NSFetchRequest<Snippet> = Snippet.fetchRequest()
        r.sortDescriptors = [
            NSSortDescriptor(keyPath: \Snippet.order, ascending: true),
            NSSortDescriptor(keyPath: \Snippet.createDate, ascending: true)
        ]
        return r
    }
    static func replacementRuleFetchRequest() -> NSFetchRequest<ReplacementRule> {
        let request = NSFetchRequest<ReplacementRule>(entityName: "ReplacementRule")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ReplacementRule.order, ascending: true)]
        return request
    }
}
