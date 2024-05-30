//
//  StorageClient.swift
//  Catch
//
//  Created by ronan.ociosoig on 27/05/2024.
//  Copyright © 2024 Sonomos.com. All rights reserved.
//

import Dependencies
import Foundation

struct StorageClient {
    var load: @Sendable (_ fileName: String, _ directory: Directory) -> Data?
    var save: @Sendable (_ data: Data, _ fileName: String, _ directory: Directory) throws -> Void
    var remove: @Sendable (_ fileName: String, _ directory: Directory) -> Void
}

// It isn't possible to use generics on computed properties
extension StorageClient: DependencyKey {
    static var liveValue = StorageClient(
        load: { fileName, directory in
            Storage.load(fileName, in: directory)
        },
        save: { object, fileName, directory in
            Storage.save(object,  as: fileName, in: directory)
        },
        remove: { fileName, directory in
            Storage.remove(fileName, in: directory)
        }
    )
    
    static var testValue = StorageClient(
        load: { fileName, directory in
            let mockPokemon: LocalPokemon = .mock
            let pokemons = [mockPokemon]
            let encoder = JSONEncoder()
            do {
                return try encoder.encode(pokemons)
            } catch {
                fatalError("Failed to encode mock data")
            }
            return Data()
        },
        save: { object, fileName, directory in
        },
        remove: { fileName, directory in
        }
    )
}

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
