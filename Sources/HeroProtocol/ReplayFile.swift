//
//  ReplayFile.swift
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

enum ReplayFileErrors: Error {
    case unableToOpenFile
    case unableToReadVersion
    case modulesPathNotSet
    case unableToReadData
    case unableToExtractFile
}

public class ReplayFile {
    private var archive: MPQArchive
    private let heroProtocolBridge: PythonObject
    private let heroProtocol: PythonObject
    
    public init(replayFileURL: URL) throws {
        if HeroProtocol.shared.modulesPath == nil {
            throw ReplayFileErrors.modulesPathNotSet
        }
        
        archive = try MPQArchive(fileURL: replayFileURL)
        let basicProtocolModule = Python.import("protocol29406")
        heroProtocolBridge = Python.import("heroprotocolbridge")
        
        let header = heroProtocolBridge.callMember("getReplayHeader", with: basicProtocolModule, archive.userDataHeaderContents)
        let baseBuild = Int(header["m_version"]["m_baseBuild"]) ?? 0
        
        if baseBuild == 0 {
            throw ReplayFileErrors.unableToReadVersion
        }
        
        let protocolName = "protocol\(baseBuild)"
        heroProtocol = Python.import(protocolName)
    }
    
    private func convert(object: PythonObject) throws -> [String: AnyObject] {
        if let stringDetails = String(object), let data = stringDetails.data(using: .utf8),
            let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, AnyObject> {
            return json
        
        } else {
            throw ReplayFileErrors.unableToReadData
        }
    }
    
    private func convert(object: PythonObject) throws -> [[String: AnyObject]] {
        var array: [[String: AnyObject]] = [[:]]
        for subobject in object {
            if let stringDetails = String(subobject), let data = stringDetails.data(using: .utf8),
                let json = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? Dictionary<String, AnyObject> {
                array.append(json)
                
            } else {
                throw ReplayFileErrors.unableToReadData
            }
        }
        
        return array
    }
    
    public func loadReplayDetails() throws -> [String: AnyObject] {
        let bytes = try archive.extractFile(filename: "replay.details", writeToDisk: false)
        let result = heroProtocolBridge.callMember("getReplayDetails", with: heroProtocol, bytes)       
        return try convert(object: result)
    }
    
    public func loadInitData() throws -> [String: AnyObject] {
        let bytes = try archive.extractFile(filename: "replay.initData", writeToDisk: false)
        let result = heroProtocolBridge.callMember("getReplayInitData", with: heroProtocol, bytes)
        return try convert(object: result)
    }
    
    public func loadMessageEvents() throws -> [[String: AnyObject]] {
        let bytes = try archive.extractFile(filename: "replay.message.events", writeToDisk: false)
        let result = heroProtocolBridge.callMember("getReplayMessageEvents", with: heroProtocol, bytes)
        return try convert(object: result)
    }
    
    public func loadAttributesEvents() throws -> [[String: AnyObject]] {
        let bytes = try archive.extractFile(filename: "replay.attributes.events", writeToDisk: false)
        let result = heroProtocolBridge.callMember("getReplayAttributesEvents", with: heroProtocol, bytes)
        return try convert(object: result)
    }
    
    public func loadTrackerEvents() throws -> [[String: AnyObject]] {
        let bytes = try archive.extractFile(filename: "replay.tracker.events", writeToDisk: false)
        let result = heroProtocolBridge.callMember("getReplayTrackerEvents", with: heroProtocol, bytes)
        return try convert(object: result)
    }
    
    public func loadGameEvents() throws -> [[String: AnyObject]] {
        let bytes = try archive.extractFile(filename: "replay.game.events", writeToDisk: false)
        let result = heroProtocolBridge.callMember("getReplayGameEvents", with: heroProtocol, bytes)
        return try convert(object: result)
    }
    
    public func loadHeaderInfo() throws -> [String: AnyObject] {
        let bytes = archive.userDataHeaderContents
        let result = heroProtocolBridge.callMember("getReplayHeaderInfo", with: heroProtocol, bytes)
        return try convert(object: result)
    }
}
