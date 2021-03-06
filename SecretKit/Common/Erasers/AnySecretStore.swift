import Foundation
import Combine

public class AnySecretStore: SecretStore {

    let base: Any
    fileprivate let _isAvailable: () -> Bool
    fileprivate let _id: () -> UUID
    fileprivate let _name: () -> String
    fileprivate let _secrets: () -> [AnySecret]
    fileprivate let _sign: (Data, AnySecret) throws -> Data
    fileprivate var sink: AnyCancellable?

    public init<SecretStoreType>(_ secretStore: SecretStoreType) where SecretStoreType: SecretStore {
        base = secretStore
        _isAvailable = { secretStore.isAvailable }
        _name = { secretStore.name }
        _id = { secretStore.id }
        _secrets = { secretStore.secrets.map { AnySecret($0) } }
        _sign = { try secretStore.sign(data: $0, with: $1.base as! SecretStoreType.SecretType) }
        sink = secretStore.objectWillChange.sink { _ in
            self.objectWillChange.send()
        }
    }

    public var isAvailable: Bool {
        return _isAvailable()
    }

    public var id: UUID {
        return _id()
    }

    public var name: String {
        return _name()
    }

    public var secrets: [AnySecret] {
        return _secrets()
    }

    public func sign(data: Data, with secret: AnySecret) throws -> Data {
        try _sign(data, secret)
    }

}

public class AnySecretStoreModifiable: AnySecretStore, SecretStoreModifiable {

    fileprivate let _create: (String, Bool) throws -> Void
    fileprivate let _delete: (AnySecret) throws -> Void

    public init<SecretStoreType>(modifiable secretStore: SecretStoreType) where SecretStoreType: SecretStoreModifiable {
        _create = { try secretStore.create(name: $0, requiresAuthentication: $1) }
        _delete = { try secretStore.delete(secret: $0.base as! SecretStoreType.SecretType) }
        super.init(secretStore)
    }

    public func create(name: String, requiresAuthentication: Bool) throws {
        try _create(name, requiresAuthentication)
    }

    public func delete(secret: AnySecret) throws {
        try _delete(secret)
    }

}
