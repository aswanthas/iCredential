//
//  CryptoHelper.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import Foundation
import CryptoKit

class CryptoHelper {
    // Static key used for encryption and decryption.
    static let key = SymmetricKey(size: .bits256)
    
    // Encrypt a string and return the base64 encoded encrypted string.
    static func encrypt(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else {
            print("Error: Could not convert string to data.")
            return nil
        }
        do {
            // Encrypt the data using AES-GCM.
            let sealedBox = try AES.GCM.seal(data, using: key)
            let base64EncodedString = sealedBox.combined?.base64EncodedString()
            print("Encrypted string: \(base64EncodedString ?? "nil")")
            return base64EncodedString
        } catch {
            print("Error encrypting: \(error)")
            return nil
        }
    }
    
    // Decrypt a base64 encoded encrypted string.
    static func decrypt(_ base64EncodedString: String) -> String? {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            print("Error: The input string is not valid Base64.")
            return nil
        }
        do {
            // Attempt to decrypt the data.
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                print("Error: Failed to convert decrypted data to string.")
                return nil
            }
            return decryptedString
        } catch {
            print("Error decrypting: \(error)")
            return nil
        }
    }
    
    // Encrypt raw data and return the encrypted data.
    static func encryptData(_ data: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Error encrypting data: \(error)")
            return nil
        }
    }
    
    // Decrypt raw encrypted data.
    static func decryptData(_ data: Data) -> Data? {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            print("Error decrypting data: \(error)")
            return nil
        }
    }
}
