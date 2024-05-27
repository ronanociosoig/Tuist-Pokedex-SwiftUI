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
    var clear: @Sendable (_ fileName: String, _ directory: Directory) -> Void
}

// It isn't possible to use generics on computed properties
extension StorageClient: DependencyKey {
    static var liveValue = StorageClient(
        load: { fileName, directory in
            Storage.load(fileName, from: directory)
        },
        save: { object, fileName, directory in
            Storage.save(object, to: directory, as: fileName)
        },
        clear: { fileName, directory in
            Storage.remove(fileName, from: directory)
        }
    )
    
    static var testValue = StorageClient(
        load: { fileName, directory in
            return Data()
        },
        save: { object, fileName, directory in
        },
        clear: { fileName, directory in
        }
    )
}

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}
