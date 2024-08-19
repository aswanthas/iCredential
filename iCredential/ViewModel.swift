//
//  ViewModel.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import Foundation
import CoreData
import SwiftUI

public final class ViewModel: ObservableObject {
    @Published var currentView: AppView = .lockScreen
    @Published var savedPasswords: [Cridentials] = []
    var coreDataContainer: NSPersistentContainer
    @Published var isLoading: Bool = false
    @Published var errorMessage: AppError? = nil
    @Published var isShowAddCridentalView: Bool = false
    @Published var isShowDetailCridentalView: Bool = false
    var selectedCridential: Cridentials? = nil
    
    init() {
        coreDataContainer = NSPersistentContainer(name: "PasswordCridentialContainer")
        coreDataContainer.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                self.handleError("Error loading Core Data: \(error.localizedDescription)")
            }
        }
        fetchPasswordCridentials()
    }
    
    func fetchPasswordCridentials() {
        isLoading = true
        errorMessage = nil // Clear previous error
        coreDataContainer = NSPersistentContainer(name: "PasswordCridentialContainer")
        coreDataContainer.loadPersistentStores { (description, error) in
            if let error = error as NSError? {
                self.handleError("Error loading Core Data: \(error.localizedDescription)")
            }
        }
        let request = NSFetchRequest<Cridentials>(entityName: "Cridentials")
        
        coreDataContainer.viewContext.perform {
            do {
                let fetchedPasswords = try self.coreDataContainer.viewContext.fetch(request)
                DispatchQueue.main.async {
                    self.savedPasswords = fetchedPasswords
                    self.isLoading = false
                }
            } catch let error as NSError {
                self.handleError("Error fetching data: \(error.localizedDescription)")
            }
        }
    }

    func addNewCridential(accountName: String, userName: String, password: String) {
        isLoading = true
        errorMessage = nil // Clear previous error
        coreDataContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let newPasswordCridential = Cridentials(context: context)
            newPasswordCridential.accountName = accountName
            newPasswordCridential.userName = userName
            if let encryptedPassword = CryptoHelper.encrypt(password) {
                newPasswordCridential.password = encryptedPassword
            } else {
                self.handleError("Error encrypting password")
                return
            }
            
            do {
                try context.save()
                DispatchQueue.main.async {
                    self.fetchPasswordCridentials() // Update after saving
                }
            } catch let error as NSError {
                self.handleError("Error saving cridential: \(error.localizedDescription)")
            }
        }
    }

    func deleteCridential(data: Cridentials?) {
        isLoading = true
        errorMessage = nil // Clear previous error
        guard let data = data else {
            self.handleError("Unable to delete the credential. Please try again.")
            return
        }
        coreDataContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let objectId = data.objectID
            do {
                // Fetch the object in the background context
                let object = try context.existingObject(with: objectId)
                context.delete(object)
                try context.save()
                DispatchQueue.main.async {
                    self.fetchPasswordCridentials() // Update after deletion
                }
            } catch let error as NSError {
                self.handleError("Error deleting credential: \(error.localizedDescription)")
            }
        }
    }

    func updateCridential(data: Cridentials?, accountName: String, userName: String, password: String) {
        isLoading = true
        errorMessage = nil // Clear previous error
        guard let data = data else {
            self.handleError("Unable to update the credential. Please try again.")
            return
        }
        coreDataContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let objectId = data.objectID
            do {
                // Fetch the object in the background context
                let object = try context.existingObject(with: objectId) as? Cridentials
                if let object = object {
                    object.accountName = accountName
                    object.userName = userName
                    if let encryptedPassword = CryptoHelper.encrypt(password) {
                        object.password = encryptedPassword
                    } else {
                        self.handleError("Error encrypting password")
                        return
                    }
                    try context.save()
                    DispatchQueue.main.async {
                        self.fetchPasswordCridentials() // Update after updating
                    }
                } else {
                    self.handleError("Error: Object not found in the current context")
                }
            } catch let error as NSError {
                self.handleError("Error updating credential: \(error.localizedDescription)")
            }
        }
    }
    
    func decryptedPassword(data: String) -> String {
        print("decryptedPassword: \(data)")
        return CryptoHelper.decrypt(data) ?? ""
    }
    
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = AppError(message: message)
            self.isLoading = false
        }
    }
}

struct AppError: Identifiable {
    let id = UUID() // Each instance will have a unique ID
    let message: String
}

enum AppView {
    case lockScreen
    case homeView
}
