//
//  HeroProtocol.swift
//  HeroProtocol
//
//  Created by Gabriel Nica on 26/07/2018.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Foundation
import MPQArchive
import PythonBridge

public struct HeroProtocolLogOptions: OptionSet {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none               = HeroProtocolLogOptions(rawValue: 1 << 0)
    public static let replayHeader       = HeroProtocolLogOptions(rawValue: 1 << 1)
    public static let gameEvents         = HeroProtocolLogOptions(rawValue: 1 << 2)
    public static let messageEvents      = HeroProtocolLogOptions(rawValue: 1 << 3)
    public static let trackerEvents      = HeroProtocolLogOptions(rawValue: 1 << 4)
    public static let attributesEvents   = HeroProtocolLogOptions(rawValue: 1 << 5)
    public static let initData           = HeroProtocolLogOptions(rawValue: 1 << 6)
    public static let details            = HeroProtocolLogOptions(rawValue: 1 << 7)
    public static let debug              = HeroProtocolLogOptions(rawValue: 1 << 8)
    
    public static let all: HeroProtocolLogOptions = [.replayHeader, .gameEvents, .messageEvents, .trackerEvents, .attributesEvents, .details, .debug]
}

public class HeroProtocol {
    public static let shared = HeroProtocol()
    public var modulesPath: String?
    
    private init() { }
    
    public func setPath(path: String) {
        let bridgePath = FileManager.default.currentDirectoryPath + "/py-heroprotocol/heroprotocolbridge.py"
        if !FileManager.default.fileExists(atPath: bridgePath) {
            fatalError("Unable to find heroprotocolbridge.py")
        }
        
        let systemPaths = [String](Python.import("sys").path) ?? []
        
        modulesPath = (systemPaths + [path, bridgePath]).joined(separator: ":")
        
        Python.updatePath(to: modulesPath!)
    }
}
