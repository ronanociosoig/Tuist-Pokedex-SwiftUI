//
//  FileStorage.swift
//  Common
//
//  Created by Ronan on 23/05/2019.
//  Copyright © 2019 Sonomos. All rights reserved.
//

import Foundation

public protocol Mocking {
    static var mock: Self { get }
}

public enum Directory {
    case documents
    case caches
}

public protocol Storing {
    static func fileExists(fileName: String, in directory: Directory) -> Bool
    static func load(_ fileName: String, in directory: Directory) -> Data
    // static func load<T: Decodable>(_ fileName: String, in directory: Directory, as type: T.Type) -> T?
    static func save(_ data: Data, as fileName: String, in directory: Directory)
    // static func save<T: Encodable>(_ object: T, as fileName: String, in directory: Directory)
    static func remove(_ fileName: String, in directory: Directory)
}

public struct Storage: Storing {
    public static func load(_ fileName: String, in directory: Directory) -> Data {
        FileStorage.retrieve(fileName, in: directoryAdaptor(directory: directory))
    }
    
    public static func save(_ data: Data, as fileName: String, in directory: Directory) {
        FileStorage.store(data, in: directoryAdaptor(directory: directory), as: fileName)
    }
    
    public static func save<T>(_ object: T, as fileName: String, in directory: Directory) where T: Encodable {
        FileStorage.store(object as! Data, as: fileName, in: directoryAdaptor(directory: directory))
    }
    
    public static func load<T>(_ fileName: String, in directory: Directory, as type: T.Type) -> T? where T: Decodable {
        if fileExists(fileName: fileName, in: directory) {
            return FileStorage.retrieve(fileName, in: directoryAdaptor(directory: directory), as: T.self)
        }
        
        return nil
    }
    
    public static func fileExists(fileName: String, in directory: Directory) -> Bool {
        return FileStorage.fileExists(fileName, in: directoryAdaptor(directory: directory))
    }
    
    public static func remove(_ fileName: String, in directory: Directory) {
        FileStorage.remove(fileName, in: directoryAdaptor(directory: directory))
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

