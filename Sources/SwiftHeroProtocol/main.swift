//
//  main.swift
//  SwiftHeroProtocol
//
//  Created by Gabriel Nica on 26/07/2018.
//  Copyright © 2017 Gabriel Nica.
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
import HeroProtocol


var options = HeroProtocolLogOptions.debug

struct CommandLineArgument {
    var short: String
    var long: String
    var usage: String
    var isInput: Bool
    var action: () -> Void
    
    func description() -> String {
        if short == "" {
            return "\t\(long) - \(usage)"
        } else {
            return "\t\(short)\(long != "" ? ", \(long)" : "") - \(usage)"
        }
    }
}

let showHeadersArg = CommandLineArgument(short: "", long: "--header", usage: "Print protocol header", isInput: false) {
    options.insert(.replayHeader)
}

let gameEventsArg = CommandLineArgument(short: "", long: "--gameevents", usage: "Print game events", isInput: false) {
    options.insert(.gameEvents)
}

let trackerEventsArg = CommandLineArgument(short: "", long: "--trackerevents", usage: "Print tracker events", isInput: false) {
    options.insert(.gameEvents)
}

let messageEventsArg = CommandLineArgument(short: "", long: "--messageevents", usage: "Print message event", isInput: false) {
    options.insert(.messageEvents)
}

let attributesArg = CommandLineArgument(short: "", long: "--attributeevents", usage: "Print attributes events", isInput: false) {
    options.insert(.attributesEvents)
}

let detailsArg = CommandLineArgument(short: "", long: "--details", usage: "Print protocol details", isInput: false) {
    options.insert(.details)
}

let initDataArg = CommandLineArgument(short: "", long: "--initdata", usage: "Print protocol initdata", isInput: false) {
    options.insert(.details)
}

let helpArg = CommandLineArgument(short: "-h", long: "--help", usage: "show this help message and exit", isInput: false) {
    options.insert(.details)
}

let fileArg = CommandLineArgument(short: "replay_file", long: "", usage: ".StormReplay file to load", isInput: true) {
    
}

let arguments = [fileArg, helpArg, gameEventsArg, messageEventsArg, trackerEventsArg, attributesArg, showHeadersArg, detailsArg, initDataArg]

func printUsage() {
    print("Shows information about a .StormReplay file")
    
    var usage = "\nusage: swiftheroprotocol "
    
    for argument in arguments {
        usage += "\(argument.isInput ? "" : "[")\(argument.short != "" ? argument.short : argument.long)\(argument.isInput ? "" : "]") "
    }
    
    print(usage + "\n")
    
    for argument in arguments {
        print(argument.description())
    }
}

var filePath = ""
let args = [String](CommandLine.arguments[1 ..< CommandLine.arguments.count])
print("SwiftHeroProtocol v1.0")

if args.count == 0 {
    printUsage()
} else {
    var usedArgs = Set<String>()
    for option in args {
        if let argument = arguments.first(where: { $0.short == option || $0.long == option}) {
            argument.action()
            usedArgs.insert(option)
        }
    }
    
    let unusedArgs = usedArgs.symmetricDifference(args)
    
    if unusedArgs.count > 1 {
        printUsage()
    } else {
        if let fileArgument = unusedArgs.first {
            filePath = fileArgument
        }
    }
}


// MARK: - Logic -

extension Dictionary {
    var prettyPrintedJSON: String? {
        do {
            let data: Data = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(data: data, encoding: .utf8)
        } catch _ {
            return nil
        }
    }
}

let modulesPath = FileManager.default.currentDirectoryPath + "/py-heroprotocol/heroprotocol-master"

HeroProtocol.shared.setPath(path: modulesPath)

let replayURL = URL(fileURLWithPath: filePath)
do {
    MPQArchive.logOptions = [.none]
    let replayFile = try ReplayFile(replayFileURL: replayURL)
    
    if options.contains(.details) {
        let data = try replayFile.loadReplayDetails()
        if let json = data.prettyPrintedJSON {
            print(json)
        }
    }
    
    if options.contains(.replayHeader) {
        let data = try replayFile.loadHeaderInfo()
        if let json = data.prettyPrintedJSON {
            print(json)
        }
    }
    
    if options.contains(.initData) {
        let data = try replayFile.loadInitData()
        if let json = data.prettyPrintedJSON {
            print(json)
        }
    }
    
    if options.contains(.messageEvents) {
        let data = try replayFile.loadMessageEvents()
        for subdata in data {
            if let json = subdata.prettyPrintedJSON {
                print(json)
            }
        }
    }
    
    if options.contains(.trackerEvents) {
        let data = try replayFile.loadTrackerEvents()
        for subdata in data {
            if let json = subdata.prettyPrintedJSON {
                print(json)
            }
        }
    }
    
    if options.contains(.attributesEvents) {
        let data = try replayFile.loadAttributesEvents()
        for subdata in data {
            if let json = subdata.prettyPrintedJSON {
                print(json)
            }
        }
    }
    
    if options.contains(.gameEvents) {
        let data = try replayFile.loadGameEvents()
        for subdata in data {
            if let json = subdata.prettyPrintedJSON {
                print(json)
            }
        }
    }
} catch (let error) {
    print("Error while reading file: \(error)")
}



