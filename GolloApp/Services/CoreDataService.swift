//
//  CoreDataService.swift
//  PromosGollo
//
//  Created by Jonathan Rodriguez on 27/9/22.
//

import CoreData
import UIKit

class CoreDataService {
    func addCarItems(with items: [CartItemDetail], warranty: [Warranty]) -> UUID? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CarProduct", in: context)
        let warrantyEntity = NSEntityDescription.entity(forEntityName: "ProductWarranty", in: context)
        var idCarProduct: UUID?
        for item in items {
            let carItem = NSManagedObject(entity: entity!, insertInto: context)
            let id = UUID()
            idCarProduct = id
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
            carItem.setValue(item.montoBonoProveedor, forKey: "providerBonusAmount")
            carItem.setValue(item.codRegalia, forKey: "codRegalia")
            carItem.setValue(item.descRegalia, forKey: "descRegalia")
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
            return idCarProduct
        } catch let error as NSError {
            print("Error addCarItems: " + error.localizedDescription)
            return nil
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
                        montoBonoProveedor: data.value(forKey: "providerBonusAmount") as? Double ?? 0.0,
                        codRegalia: data.value(forKey: "codRegalia") as? String ?? "",
                        descRegalia: data.value(forKey: "descRegalia") as? String ?? "",
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

    func addProductFavorite(with item: Product, name: String?) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Favorites", in: context)
        let favoriteItem = NSManagedObject(entity: entity!, insertInto: context)
        let id = UUID()
        favoriteItem.setValue(id, forKey: "idFavoriteProduct")
        favoriteItem.setValue(item.brand, forKey: "brand")
        favoriteItem.setValue(item.descriptionDetailBono, forKey: "descriptionDetailBono")
        favoriteItem.setValue(item.descriptionDetailDescuento, forKey: "descriptionDetailDescuento")
        favoriteItem.setValue(item.descriptionDetailRegalia, forKey: "descriptionDetailRegalia")
        favoriteItem.setValue(item.endDate, forKey: "endDate")
        favoriteItem.setValue(item.id, forKey: "id")
        favoriteItem.setValue(item.idEmpresa, forKey: "idEmpresa")
        favoriteItem.setValue(item.idUsuario, forKey: "idUsuario")
        favoriteItem.setValue(item.image, forKey: "image")
        favoriteItem.setValue(item.modelo, forKey: "modelo")
        favoriteItem.setValue(item.montoBono, forKey: "montoBono")
        favoriteItem.setValue(item.montoDescuento, forKey: "montoDescuento")
        favoriteItem.setValue(item.name, forKey: "name")
        favoriteItem.setValue(item.originalPrice, forKey: "originalPrice")
        favoriteItem.setValue(item.porcDescuento, forKey: "porcDescuento")
        favoriteItem.setValue(item.precioFinal, forKey: "precioFinal")
        favoriteItem.setValue(item.product, forKey: "product")
        favoriteItem.setValue(item.productCode, forKey: "productCode")
        favoriteItem.setValue(item.productName, forKey: "productName")
        favoriteItem.setValue(item.productoDescription, forKey: "productoDescription")
        favoriteItem.setValue(item.startDate, forKey: "startDate")
        favoriteItem.setValue(item.tieneBono, forKey: "tieneBono")
        favoriteItem.setValue(item.tieneDescuento, forKey: "tieneDescuento")
        favoriteItem.setValue(item.tieneRegalia, forKey: "tieneRegalia")
        favoriteItem.setValue(item.tipoPromoApp, forKey: "tipoPromoApp")
        do {
            try context.save()
        } catch let error as NSError {
            print("Error addFavorite: " + error.localizedDescription)
        }
    }

    func fetchFavoriteItems() -> [Product] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        do {
            let result = try context.fetch(request)
            var favorites: [Product] = []
            for data in result as! [NSManagedObject] {
                favorites.append(
                    Product(
                        productCode: data.value(forKey: "productCode") as? String,
                        descriptionDetailDescuento: data.value(forKey: "descriptionDetailDescuento") as? String,
                        descriptionDetailRegalia: data.value(forKey: "descriptionDetailRegalia") as? String,
                        originalPrice: data.value(forKey: "originalPrice") as? Double,
                        image: data.value(forKey: "image") as? String,
                        montoBono: data.value(forKey: "montoBono") as? Double,
                        porcDescuento: data.value(forKey: "porcDescuento") as? Double,
                        brand: data.value(forKey: "brand") as? String,
                        descriptionDetailBono: data.value(forKey: "descriptionDetailBono") as? String,
                        tieneBono: data.value(forKey: "tieneBono") as? String,
                        name: data.value(forKey: "name") as? String,
                        modelo: data.value(forKey: "modelo") as? String,
                        endDate: data.value(forKey: "endDate") as? String,
                        tieneRegalia: data.value(forKey: "tieneRegalia") as? String,
                        simboloMoneda: SimboloMoneda.empty,
                        id: data.value(forKey: "id") as? Int,
                        montoDescuento: data.value(forKey: "montoDescuento") as? Double,
                        idUsuario: data.value(forKey: "idUsuario") as? String,
                        product: data.value(forKey: "product") as? String,
                        idEmpresa: data.value(forKey: "idEmpresa") as? Int,
                        startDate: data.value(forKey: "startDate") as? String,
                        precioFinal: data.value(forKey: "precioFinal") as? Double,
                        productName: data.value(forKey: "productName") as? String,
                        tieneDescuento: data.value(forKey: "tieneDescuento") as? String,
                        tipoPromoApp: data.value(forKey: "tipoPromoApp") as? Int,
                        productoDescription: data.value(forKey: "productoDescription") as? String,
                        muestraDescuento: "false"
                    )
                )
            }
            return favorites
        } catch let error as NSError {
            print("Error fetchCarItems: " + error.localizedDescription)
            return []
        }
    }

    func deleteFavorite(with id: UUID) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        request.predicate = NSPredicate(format: "idFavoriteProduct == %@", id as CVarArg)
        do {
            let result = try context.fetch(request)
            for object in result {
                context.delete(object as! NSManagedObject)
            }
            try context.save()
            return true
        } catch let error as NSError {
            print("Error favoriteItem: " + error.localizedDescription)
            return false
        }
    }

    func isFavoriteProduct(with code: String) -> UUID? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorites")
        request.predicate = NSPredicate(format: "productCode == %@", code as CVarArg)
        do {
            let result = try context.fetch(request)
            var id: UUID?
            for object in result {
                id = (object as! NSManagedObject).value(forKey: "idFavoriteProduct") as? UUID
            }
            return id
        } catch let error as NSError {
            print("Error favoriteItem: " + error.localizedDescription)
            return nil
        }
    }
}
