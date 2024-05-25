//
//  FileStorage.swift
//  Common
//
//  Created by Ronan on 23/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import Dependencies
import Foundation

public protocol Mocking {
    static var mock: Self { get }
}

extension Storage: DependencyKey {
    public static let liveValue = Storage()
    
    public static var testValue: Storage {
        return Storage()
    }
}

public enum Directory {
    case documents
    case caches
}

public protocol Storing {
    static func fileExists(fileName: String, in directory: Directory) -> Bool
    static func save<T: Encodable>(_ object: T, to directory: Directory, as fileName: String)
    static func load<T: Decodable>(_ fileName: String, from directory: Directory, as type: T.Type) -> T?
    static func remove(_ fileName: String, from directory: Directory)
    
    static func load(_ fileName: String, from directory: Directory) -> Data
    static func save(_ data: Data, to directory: Directory, as fileName: String)
}

struct StorageUnit {
    var load: @Sendable (_ fileName: String, _ directory: Directory) -> Data?
    var save: @Sendable (_ data: Data, _ fileName: String, _ directory: Directory) throws -> Void
}

// It isn't possible to use generics on computed properties
extension StorageUnit: DependencyKey {
    static var liveValue = StorageUnit(
        load: { fileName, directory in
            Storage.load(fileName, from: directory)
        },
        save: { object, fileName, directory in
            Storage.save(object, to: directory, as: fileName)
        }
    )
    
    static var testValue = StorageUnit(
        load: { fileName, directory in
            return Data()
        },
        save: { object, fileName, directory in
        }
    )
}

extension DependencyValues {
    var storageUnit: StorageUnit {
        get { self[StorageUnit.self] }
        set { self[StorageUnit.self] = newValue }
    }
}

public struct Storage: Storing {
    public init() {
        
    }
    public static func load(_ fileName: String, from directory: Directory) -> Data {
        FileStorage.retrieve(fileName, from: directoryAdaptor(directory: directory))
    }
    
    public static func save(_ data: Data, to directory: Directory, as fileName: String) {
        FileStorage.store(data, to: directoryAdaptor(directory: directory), as: fileName)
    }
    
    public static func save<T>(_ object: T, to directory: Directory, as fileName: String) where T: Encodable {
        FileStorage.store(object, to: directoryAdaptor(directory: directory), as: fileName)
    }
    
    public static func load<T>(_ fileName: String, from directory: Directory, as type: T.Type) -> T? where T: Decodable {
        if fileExists(fileName: fileName, in: directory) {
            return FileStorage.retrieve(fileName, from: directoryAdaptor(directory: directory), as: T.self)
        }
        
        return nil
    }
    
    public static func fileExists(fileName: String, in directory: Directory) -> Bool {
        return FileStorage.fileExists(fileName, in: directoryAdaptor(directory: directory))
    }
    
    public static func remove(_ fileName: String, from directory: Directory) {
        FileStorage.remove(fileName, from: directoryAdaptor(directory: directory))
    }
    
    private static func directoryAdaptor(directory: Directory) -> FileStorage.Directory {
        switch directory {
        case Directory.documents:
            return FileStorage.Directory.documents
        case Directory.caches:
            return FileStorage.Directory.caches
        }
    }
}
