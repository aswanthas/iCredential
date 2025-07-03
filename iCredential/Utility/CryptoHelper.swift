//
//  CryptoHelper.swift
//  iCridentialsSaver
//
//  Created by Aswanth K on 15/06/24.
//

import Foundation
import CryptoKit
import Security

class CryptoHelper {
    private static let keychainKey = "com.yourapp.symmetricKey"

    // MARK: - Public: Encrypt
    static func encrypt(_ string: String) -> String? {
        guard let data = string.data(using: .utf8) else {
            print("Encryption error: Unable to convert string to data.")
            return nil
        }

        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }

    // MARK: - Public: Decrypt
    static func decrypt(_ base64EncodedString: String) -> String? {
        guard let data = Data(base64Encoded: base64EncodedString) else {
            print("Decryption error: Invalid Base64 input.")
            return nil
        }

        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }

    // MARK: - Private: Symmetric Key Access
    private static var key: SymmetricKey {
        if let existingKey = loadKeyFromKeychain() {
            return SymmetricKey(data: existingKey)
        } else {
            let newKey = SymmetricKey(size: .bits256)
            saveKeyToKeychain(key: newKey)
            return newKey
        }
    }

    // MARK: - Private: Save Key to Keychain
    private static func saveKeyToKeychain(key: SymmetricKey) {
        let tag = keychainKey
        let keyData = key.withUnsafeBytes { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemDelete(query as CFDictionary) // Remove old key if exists

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain save error: \(status)")
        }
    }

    // MARK: - Private: Load Key from Keychain
    private static func loadKeyFromKeychain() -> Data? {
        let tag = keychainKey

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        } else {
            print("Keychain load error: \(status)")
            return nil
        }
    }
}
