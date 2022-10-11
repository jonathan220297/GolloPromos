//
//  CoreDataService.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import CoreData
import UIKit

class CoreDataService {
    func addCarItems(with items: [CartItemDetail], warranty: [Warranty]) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CarProduct", in: context)
        let warrantyEntity = NSEntityDescription.entity(forEntityName: "ProductWarranty", in: context)
        for item in items {
            let carItem = NSManagedObject(entity: entity!, insertInto: context)
            let id = UUID()
            carItem.setValue(id, forKey: "idCarProduct")
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
            for w in warranty {
                let carWarranty = NSManagedObject(entity: warrantyEntity!, insertInto: context)
                carWarranty.setValue(w.plazoMeses ?? 0, forKey: "months")
                carWarranty.setValue(w.impuestoExtragarantia ?? 0.0, forKey: "taxes")
                carWarranty.setValue(w.montoExtragarantia ?? 0.0, forKey: "amount")
                carWarranty.setValue(w.porcentaje ?? 0.0, forKey: "percentage")
                carWarranty.setValue(w.titulo ?? "", forKey: "title")
                carWarranty.setValue(id, forKey: "idCarProduct")
                carItem.setValue(NSSet(object: carWarranty), forKey: "productWarranty")
            }
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
                        precioUnitario: data.value(forKey: "unitPrice") as? Double ?? 0.0,
                        warranty: data.value(forKey: "productWarranty") as? [Warranty] ?? []
                    )
                )
            }
            return car
        } catch let error as NSError {
            print("Error fetchCarItems: " + error.localizedDescription)
            return []
        }
    }

    func fetchCarWarranty(with id: UUID) -> [Warranty] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ProductWarranty")
        request.predicate = NSPredicate(format: "idCarProduct == %@", id as CVarArg)
        do {
            let result = try context.fetch(request)
            var warranty: [Warranty] = []
            for data in result as! [NSManagedObject] {
                warranty.append(
                    Warranty(
                        plazoMeses: data.value(forKey: "months") as? Int ?? 0,
                        porcentaje: data.value(forKey: "percentage") as? Double ?? 0.0,
                        montoExtragarantia: data.value(forKey: "amount") as? Double ?? 0.0,
                        impuestoExtragarantia: data.value(forKey: "taxes") as? Double ?? 0.0,
                        titulo: data.value(forKey: "title") as? String ?? ""
                    )
                )
            }
            return warranty
        } catch let error as NSError {
            print("Error fetchWarranties: " + error.localizedDescription)
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
    
    func updateProductQuantity(for productID: UUID, _ quantity: Int) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarProduct")
        request.predicate = NSPredicate(format: "idCarProduct == %@", productID as CVarArg)
        do {
            let result = try context.fetch(request)
            if let item = result.first as? NSManagedObject {
                item.setValue(quantity, forKey: "quantity")
            }
            try context.save()
            return true
        } catch let error as NSError {
            print("Error deleteCarItem: " + error.localizedDescription)
            return false
        }
    }

    func addGolloPlus(for productID: UUID, month: Int, amount: Double) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarProduct")
        request.predicate = NSPredicate(format: "idCarProduct == %@", productID as CVarArg)
        do {
            let result = try context.fetch(request)
            if let item = result.first as? NSManagedObject {
                item.setValue(month, forKey: "warranty")
                item.setValue(amount, forKey: "warrantyAmount")
            }
            try context.save()
            return true
        } catch let error as NSError {
            print("Error error adding GolloPlus: " + error.localizedDescription)
            return false
        }
    }

    func removeGolloPlus(for productID: UUID) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarProduct")
        request.predicate = NSPredicate(format: "idCarProduct == %@", productID as CVarArg)
        do {
            let result = try context.fetch(request)
            if let item = result.first as? NSManagedObject {
                item.setValue(0, forKey: "warranty")
                item.setValue(0.0, forKey: "warrantyAmount")
            }
            try context.save()
            return true
        } catch let error as NSError {
            print("Error deleteCarItem: " + error.localizedDescription)
            return false
        }
    }
}
