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
    
    private init () {}
}
