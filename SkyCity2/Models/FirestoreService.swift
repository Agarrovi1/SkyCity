//
//  FirestoreService.swift
//  SkyCity2
//
//  Created by Angela Garrovillas on 12/16/19.
//  Copyright © 2019 Angela Garrovillas. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FireStoreCollections: String {
    case users
    case plotsOfLand
    case buildings
    
}



class FirestoreService {
    static let manager = FirestoreService()
    
    private let db = Firestore.firestore()
    
    //MARK: AppUsers
    func createAppUser(user: AppUser, completion: @escaping (Result<(), Error>) -> ()) {
        var fields = user.fieldsDict
        fields["dateCreated"] = Date()
        db.collection(FireStoreCollections.users.rawValue).document(user.uid).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
                print(error)
            }
            completion(.success(()))
        }
    }
    func updateAppUser(id: String, newFoodAmount: Int, newStarBitsAmount: Int ,completion: @escaping (Result<(),Error>) -> ()) {
        db.collection(FireStoreCollections.users.rawValue).document(id).updateData(["food": newFoodAmount,"starBits": newStarBitsAmount]) { (error) in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    func getAppUser(id: String, completion: @escaping(Result<AppUser,Error>) -> ()) {
        db.collection(FireStoreCollections.users.rawValue).document(id).getDocument { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let snapshot = snapshot {
                let userID = snapshot.documentID
                if let user = AppUser(from: snapshot.data() ?? [:], id: userID) {
                    completion(.success(user))
                }
            }
        }
    }
    
    
    //MARK: PlotsOfLand
    func createPlot(newPlot: PlotsOfLand, completion: @escaping (Result<(),Error>) -> ()) {
        let fields = newPlot.fieldsDict
        db.collection(FireStoreCollections.plotsOfLand.rawValue).document(newPlot.id).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
                print(error)
            }
            completion(.success(()))
        }
    }
    func getPlotsFor(userID: String,completion: @escaping (Result<[PlotsOfLand],Error>) -> ()) {
        db.collection(FireStoreCollections.plotsOfLand.rawValue).whereField("createdBy", isEqualTo: userID).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let plots = snapshot?.documents.compactMap({ (snapshot) -> PlotsOfLand? in
                    let plotID = snapshot.documentID
                    let plot = PlotsOfLand(from: snapshot.data(), id: plotID)
                    return plot
                })
                completion(.success(plots ?? []))
            }
        }
    }
    func findIdOfPlot(x: Double,y: Double, userId: String, completionHandler: @escaping (Result<String,Error>) -> ()) {
        db.collection(FireStoreCollections.plotsOfLand.rawValue).whereField("createdBy", isEqualTo: userId).whereField("x", isEqualTo: x).whereField("y", isEqualTo: y).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                let farmLand = snapshot?.documents.compactMap({ (snapshot) -> PlotsOfLand? in
                    let farmID = snapshot.documentID
                    let farm = PlotsOfLand(from: snapshot.data(), id: farmID)
                    return farm
                })
                if let farmLand = farmLand {
                    completionHandler(.success(farmLand[0].id))
                }
            }
        }
    }
    func updatePlot(plot: PlotNode,result: (Result<String,Error>), completion: @escaping (Result<(),Error>) -> ()) {
        switch result {
        case .success(let favId):
            db.collection(FireStoreCollections.plotsOfLand.rawValue)
                .document(favId).updateData(["plantTime": Double(plot.plantTime ?? 0.0), "maxAmountTime": plot.maxTimeAmount, "state": plot.state.rawValue, "foodValue": plot.foodValue]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    //MARK: Buildings
    func createBuilding(newBuilding: Buildings, completion: @escaping (Result<(),Error>) -> ()) {
        let fields = newBuilding.fieldsDict
        db.collection(FireStoreCollections.buildings.rawValue).document(newBuilding.id).setData(fields) { (error) in
            if let error = error {
                completion(.failure(error))
                print(error)
            }
            completion(.success(()))
        }
    }
    func getBuildingsFor(userID: String,completion: @escaping (Result<[Buildings],Error>) -> ()) {
        db.collection(FireStoreCollections.buildings.rawValue).whereField("createdBy", isEqualTo: userID).getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let buildings = snapshot?.documents.compactMap({ (snapshot) -> Buildings? in
                    let buildingID = snapshot.documentID
                    let building = Buildings(from: snapshot.data(), id: buildingID)
                    return building
                })
                completion(.success(buildings ?? []))
            }
        }
    }
    func findIdOfBuilding(x: Double,y: Double, userId: String, completionHandler: @escaping (Result<String,Error>) -> ()) {
        db.collection(FireStoreCollections.buildings.rawValue).whereField("createdBy", isEqualTo: userId).whereField("x", isEqualTo: x).whereField("y", isEqualTo: y).getDocuments { (snapshot, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else {
                let buildingLand = snapshot?.documents.compactMap({ (snapshot) -> Buildings? in
                    let buildingID = snapshot.documentID
                    let building = Buildings(from: snapshot.data(), id: buildingID)
                    return building
                })
                if let buildingLand = buildingLand {
                    completionHandler(.success(buildingLand[0].id))
                }
            }
        }
    }
    func updateBuilding(building: BuildingNode,result: (Result<String,Error>), completion: @escaping (Result<(),Error>) -> ()) {
        switch result {
        case .success(let favId):
            db.collection(FireStoreCollections.buildings.rawValue)
                .document(favId).updateData(["gettingTime": Double(building.starBitsTime ?? 0.0), "maxAmountTime": building.maxTimeAmount, "state": building.state.rawValue, "starBitValue": building.starBitValue]) { (error) in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    private init () {}
}
