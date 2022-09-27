//
//  CoreDataService.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import CoreData
import UIKit

class CoreDataService {
    func addCarItems(with items: [CartItemDetail]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CarProduct", in: context)
        for item in items {
            let carItem = NSManagedObject(entity: entity!, insertInto: context)
            carItem.setValue(UUID(), forKey: "idCarProduct")
            carItem.setValue(item.urlImage, forKey: "urlImage")
            carItem.setValue(item.descripcion, forKey: "descriptionItem")
            carItem.setValue(item.descuento, forKey: "discount")
            carItem.setValue(item.montoDescuento, forKey: "discountAmount")
            carItem.setValue(item.porcDescuento, forKey: "discountPercentage")
            carItem.setValue(item.precioExtendido, forKey: "extendedPrice")
            carItem.setValue(item.idLinea, forKey: "idLinea")
            carItem.setValue(item.cantidad, forKey: "quantity")
            carItem.setValue(item.sku, forKey: "sku")
            carItem.setValue(item.precioUnitario, forKey: "unitPrice")
            carItem.setValue(item.mesesExtragar, forKey: "warranty")
            carItem.setValue(item.montoExtragar, forKey: "warrantyAmount")
        }
        do {
            try context.save()
        } catch let error as NSError {
            print("Error addCarItems: " + error.localizedDescription)
        }
    }
    
    func fetchCarItems() -> [CartItemDetail] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarProduct")
        do {
            let result = try context.fetch(request)
            var car: [CartItemDetail] = []
            for data in result as! [NSManagedObject] {
                car.append(
                    CartItemDetail(
                        idCarItem: data.value(forKey: "idCarProduct") as? UUID,
                        urlImage: data.value(forKey: "urlImage") as? String,
                        cantidad: data.value(forKey: "quantity") as? Int ?? 0,
                        idLinea: data.value(forKey: "idLinea") as? Int ?? 0,
                        mesesExtragar: data.value(forKey: "warranty") as? Int ?? 0,
                        descripcion: data.value(forKey: "descriptionItem") as? String ?? "",
                        sku: data.value(forKey: "sku") as? String ?? "",
                        descuento: data.value(forKey: "discount") as? Double ?? 0.0,
                        montoDescuento: data.value(forKey: "discountAmount") as? Double ?? 0.0,
                        montoExtragar: data.value(forKey: "warrantyAmount") as? Double ?? 0.0,
                        porcDescuento: data.value(forKey: "discountPercentage") as? Double ?? 0.0,
                        precioExtendido: data.value(forKey: "extendedPrice") as? Double ?? 0.0,
                        precioUnitario: data.value(forKey: "unitPrice") as? Double ?? 0.0
                    )
                )
            }
            return car
        } catch let error as NSError {
            print("Error fetchCarItems: " + error.localizedDescription)
            return []
        }
    }
    
    func deleteCarItem(with id: UUID) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarProduct")
        request.predicate = NSPredicate(format: "idCarProduct == %@", id as CVarArg)
        do {
            let result = try context.fetch(request)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            return true
        } catch let error as NSError {
            print("Error deleteCarItem: " + error.localizedDescription)
            return false
        }
    }
    
    func deleteAllItems() -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarProduct")
        do {
            let result = try context.fetch(request)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            return true
        } catch let error as NSError {
            print("Error deleteAllItems: " + error.localizedDescription)
            return false
        }
    }
}
