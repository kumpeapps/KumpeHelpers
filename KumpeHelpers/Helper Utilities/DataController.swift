//
//  DataController.swift
//  KKid
//
//  Created by Justin Kumpe on 8/9/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

public class DataController {

    public let persistentContainer:NSPersistentContainer

    public var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public static var modelname = "CoreData"

    public let backgroundContext:NSManagedObjectContext!

    public init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)

        backgroundContext = persistentContainer.newBackgroundContext()
    }

    public func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true

        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }

    public func load(completion: (() -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
//            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
//  Shared Data Controller
    public static let shared = DataController(modelName: modelname)
}

public extension DataController{
    
//    MARK: Auto Save View Context
    func autoSaveViewContext(interval:TimeInterval = 30){
        Logger.log(.action, "autosaving")
        guard interval > 0 else {
            Logger.log(.error, "cannot set negative autosave inteval")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
            }
    }
    
}
