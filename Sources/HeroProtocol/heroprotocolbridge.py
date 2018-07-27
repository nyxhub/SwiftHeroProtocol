import heroprotocol
import array
import json

# transform the data into a byte string needed for protocol functions
# data is an array of unsigned bytes
def byteStringFromArray(uInt8Array):
    return array.array('B', uInt8Array).tostring()

def getReplayDetails(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    details = protocol.decode_replay_details(contents)
    return json.dumps(details, encoding="ISO-8859-1")

def getReplayInitData(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    initdata = protocol.decode_replay_initdata(contents)
    return json.dumps(initdata, encoding="ISO-8859-1")

def getReplayMessageEvents(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    events = []
    for event in protocol.decode_replay_message_events(contents):
        events.append(json.dumps(event, encoding="ISO-8859-1"))
    return events

def getReplayGameEvents(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    events = []
    for event in protocol.decode_replay_game_events(contents):
        events.append(json.dumps(event, encoding="ISO-8859-1"))
    return events

def getReplayTrackerEvents(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    events = []
    for event in protocol.decode_replay_tracker_events(contents):
        events.append(json.dumps(event, encoding="ISO-8859-1"))
    return events

def getReplayAttributesEvents(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    events = []
    for event in protocol.decode_replay_attributes_events(contents):
        events.append(json.dumps(event, encoding="ISO-8859-1"))
    return events

def getReplayHeader(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    header = protocol.decode_replay_header(contents)
    return header

def getReplayHeaderInfo(protocol, uInt8Array):
    contents = byteStringFromArray(uInt8Array)
    header = protocol.decode_replay_header(contents)
    return json.dumps(header, encoding="ISO-8859-1")
