import Foundation
import os.log

let subsystem = "com.sonomos.pokedex"

public struct Log {
    public static var general = OSLog(subsystem: subsystem, category: "general")
    public static var network = OSLog(subsystem: subsystem, category: "network")
    public static var data = OSLog(subsystem: subsystem, category: "data")
}
