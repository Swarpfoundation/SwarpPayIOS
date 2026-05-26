import Foundation
import Security

protocol SecureSessionStore {
    func save(sessionHandle: String) throws
    func loadSessionHandle() throws -> String?
    func clear() throws
}

enum SecureSessionStoreError: LocalizedError, Equatable {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case unexpectedData

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Could not save session handle to Keychain. Status: \(status)"
        case .loadFailed(let status):
            return "Could not load session handle from Keychain. Status: \(status)"
        case .deleteFailed(let status):
            return "Could not clear session handle from Keychain. Status: \(status)"
        case .unexpectedData:
            return "Keychain session data was not valid UTF-8."
        }
    }
}

final class KeychainSessionStore: SecureSessionStore {
    private let service = "com.swarppay.ios.session"
    private let account = "current"
    private let accessibility = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly

    func save(sessionHandle: String) throws {
        let data = Data(sessionHandle.utf8)
        let query = baseQuery()
        let update: [String: Any] = [
            kSecValueData as String: data,
            kSecAttrAccessible as String: accessibility
        ]
        let updateStatus = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }
        guard updateStatus == errSecItemNotFound else {
            throw SecureSessionStoreError.saveFailed(updateStatus)
        }

        var attributes = query
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = accessibility
        let addStatus = SecItemAdd(attributes as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw SecureSessionStoreError.saveFailed(addStatus)
        }
    }

    func loadSessionHandle() throws -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecItemNotFound {
            return nil
        }
        guard status == errSecSuccess else {
            throw SecureSessionStoreError.loadFailed(status)
        }
        guard let data = result as? Data,
              let value = String(data: data, encoding: .utf8)
        else {
            throw SecureSessionStoreError.unexpectedData
        }
        return value
    }

    func clear() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureSessionStoreError.deleteFailed(status)
        }
    }

    private func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
