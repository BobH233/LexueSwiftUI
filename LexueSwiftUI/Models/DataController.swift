//
//  DataController.swift
//  LexueSwiftUI
//
//  Created by bobh on 2023/9/5.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    static let shared = DataController()
    let container = NSPersistentContainer(name: "MessageModel")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("fatal: Failed to load core data! \(error.localizedDescription)")
                exit(-1)
            }
        }
    }
    
    func save(context: NSManagedObjectContext) {
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addMessageStored(senderUid: String, type: MessageBodyType, text_data: String?, image_data: String?, 
                          link_data: String, date: Date?, context: NSManagedObjectContext) {
        let msgStored = MessageStored(context: context)
        msgStored.id = UUID()
        msgStored.senderUid = senderUid
        msgStored.type = Int32(type.rawValue)
        msgStored.text_data = text_data
        msgStored.image_data = image_data
        msgStored.link_data = link_data
        msgStored.date = date ?? Date()
        save(context: context)
    }
    
}
