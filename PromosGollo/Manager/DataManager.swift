//
//  DataManager.swift
//  PromosGollo
//
//  Created by Rodrigo Osegueda on 31/8/21.
//

import UIKit
import CoreData

open class DataManager: NSObject {

    public static let sharedInstance = DataManager()

    private override init() {}

    // Helper func for getting the current context.
    private func getContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }

    // Recents Views
    func retriveRecents() -> [ProductCoreData] {
        guard let managedContext = getContext() else { return [] }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Recents")
        //let sort = NSSortDescriptor(key: #keyPath(Recents.dateSaved), ascending: false)
        //fetchRequest.sortDescriptors = [sort]
        return []
//        do {
//            let result = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
//            if result.count > 0 {
//                var products: [ProductCoreData] = []
//                for product in result {
//                    let id = product.value(forKey: "id") as! String
//                    let json = product.value(forKey: "json") as! String
//                    let dataSaved = product.value(forKey: "dateSaved") as! Date
//                    products.append(ProductCoreData(id: id, json: json, dataSaved: dataSaved))
//                }
//                return products
//            } else {
//                return []
//            }
//        } catch let error as NSError {
//            //log.debug("Retrieving user failed. \(error): \(error.userInfo)")
//            return []
//        }
    }

}
