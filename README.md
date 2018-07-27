# Swift HeroProtocol

Swift HeroProtocol is a cross platform native Swift port of Blizzard Entertainment's
heroprotocol python library for extracting component files of a Heroes of the Storm
replay file and decoding them. It comes in the form of 2 executables which can be used as is,
**swiftmpq** and **swiftheroprotocol** (the equivalent of Blizzard's **mpyq** and **heroprotocol**
python scripts). Swift HeroProtocol uses and creates 2 libraries, **MPQArchive** and **HeroProtocol**
which can be dynamically linked and used in software that needs to manipulate MPQ archives and/or
heroes of the storm replay information.

Swift HeroProtocol replicates the full functionality of both the mpyq (python library
used to extract files from a MoPaQ archives) and heroprotocol executables
and libraries. The executables have the same interface and command line parameters
as their python equivalents.

Python heroprotocol can be found [here](https://github.com/Blizzard/heroprotocol)

## MPQArchive framework

Is a complete swift port of the python **mpyq** library. It can extract all or specific files contained in
an MPQ archive both to disk or in memory. While faster than the python version it is a direct port and has
the same limitation - It shouldn't be used to extract large files so its use case should be limited to replay
files from starcraft 2 or heroes of the storm.

The library can be found standalone here: https://github.com/gabrielnica/MPQArchive

## HeroProtocol (swift) framework

The HeroProtocol swift framework contains a set of functions to decode the replay component files into native
swift types such as dictionaries or arrays. In order to not have to make a swift translation of hundreds of python
scripts and to be future proof, it makes use of Python's C interoperability to interface with the required
patch protocol through the **PythonBridge** swift framework and Swift 4.2's new `@dynamicMemberLookup` functionality.
Note that the Swift HeroProtocol library does not spawn any other system process or any other gimmick that runs the original python scripts.
It directly interfaces with Python through C interop

## About Heroes of the Storm replay files

.StormReplay files are MoPaQ archives which contain
a set of files that further contain replay information such as messages and actions taken
during a game. Those files are encrypted and tightly packed

## What happens when Blizzard releases a new patch

Each Heroes of the Storm patch has a corresponding "protocol" which contains information
about how to decode the replay files for that particular version of the game. When a
new patch is published Blizzard updates automatically the python library in the heroprotocol
github repo

The Swift HeroProtocol library requires a path to a local clone of the python heroprotocol which must be set
before any replay file can be loaded. In this way it is ensured that whenever a new patch comes out all you need
to do is a `git pull` for the heroprotocol repo and the Swift library will pick up the new version. The executable
version might do all this by itself in the future.

# Requirements

* the heroprotocol python repository cloned locally. If using the executable version of swiftheroprotocol then this python files must reside in `[executable path]/py-heroprotocol/heroprotocol-master`
* Xcode 10 (although not necessary if you use swift command line to build)
* Apple Swift version 4.2-dev toolchain or up (at least LLVM da1c9a3ae4, Clang 78aa734eee, Swift 18650bc69c)
* Python 2.7.14 installed with homebrew. If installed through other means the modulemap paths need to be changed. Ensure that `/usr/local/Cellar/python/2.7.14/Frameworks/Python.framework` exists
* ZLib C library
* BZip2 1.0.6 library installed with homebrew. Ensure that BZip2 is installed in `/usr/local/Cellar/bzip2/1.0.6_1`. If installed in different location you must modify the modulemap for bzip2 in MPQArchive

# Instalation

* Copy the `heroprotocolbridge.py` file from `Sources/HeroProtocol/` into `[executable or target path]/py-heroprotocol/`. This is because of a limitation of SwiftPM that doesn't have a way to bundle files with a package

## Standalone

* clone the repository locally
* run `swift build` in the clone folder or if you want to open and build the project in Xcode, `swift package generate-xcodeproj`


## As a library using Swift Package Manager

Add this dependency in your package description

```swift
  .package(url: "git@github.com:gabrielnica/SwiftHeroProtocol.git", from: "1.0.0")
```

Note that this still needs the `heroprotocolbridge.py` file

# HeroProtocol Usage

All HeroProtocol .load[...] functions return either a dictionary or an array of dictionaries. For nil values within the dictionaries
it uses NSNull

```Swift
let path = "/usr/local/lib/heroprotocol-master"

HeroProtocol.shared.path = path
MPQArchive.logOptions = [.none]

let replayURL = URL(fileURLWithPath: "/Users/..../Infernal Shrines (60).StormReplay")

do {
    let replayFile = try ReplayFile(url: replayURL)
    let messages = try replayFile.loadMessageEvents()

    // messages is an array of [String: AnyObject] where each element of the array is a message

    for message in messages {
        print(message)
    }
} catch {
    print("Error while reading file: \(error)")
}
```

Available functions:

```Swift
public class ReplayFile {

    public init(replayFileURL: URL) throws

    public func loadReplayDetails() throws -> [String : AnyObject]

    public func loadInitData() throws -> [String : AnyObject]

    public func loadMessageEvents() throws -> [[String : AnyObject]]

    public func loadAttributesEvents() throws -> [[String : AnyObject]]

    public func loadTrackerEvents() throws -> [[String : AnyObject]]

    public func loadGameEvents() throws -> [[String : AnyObject]]

    public func loadHeaderInfo() throws -> [String : AnyObject]
}
```

# MPQArchive Usage

To unarchive in memory:

```swift
let replayFileURL = URL(fileURLWithPath: "/Users/..../Infernal Shrines (60).StormReplay")
do {
    let archive = try MPQArchive(fileURL: replayFileURL)
    // by now the file is already loaded and MPQArchive extracted the file list. if you don't want to that
    // and load the archive later
    // use let archive = MPQArchive(); [...] try archive.load(fileURL: replayFileURL)
    let data = try archive.extractFile(filename: "replay.message.events", writeToDisk: false)
} catch {
    print("Error while reading file: \(error)")
}
```
For more info on how to use MPQArchive see https://github.com/gabrielnica/MPQArchive
