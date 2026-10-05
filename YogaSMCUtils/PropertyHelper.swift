//
//  PropertyHelper.swift
//  YogaSMC
//
//  Created by Zhen on 10/14/20.
//  Copyright © 2020 Zhen. All rights reserved.
//

import Foundation

// from https://github.com/LinusHenze/Fugu/blob/master/USB/IOKitUSB.swift
// IOIteratorNext, Swift Style
func IOIteratorNextOptional(_ iterator: io_iterator_t) -> io_service_t? {
    let service = IOIteratorNext(iterator)
    return service != 0 ? service : nil
}

func getBoolean(_ key: String, _ service: io_service_t) -> Bool {
    guard let rvalue = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0),
          let val = rvalue.takeRetainedValue() as? Bool else {
        return false
    }
    return val
}

func getNumber(_ key: String, _ service: io_service_t) -> Int {
    guard let rvalue = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0),
          let val = rvalue.takeRetainedValue() as? Int else {
        return -1
    }
    return val
}

func getString(_ key: String, _ service: io_service_t) -> String? {
    guard let rvalue = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0),
          let val = rvalue.takeRetainedValue() as? NSString else {
        return nil
    }
    return val as String
}

func getDictionary(_ key: String, _ service: io_service_t) -> NSDictionary? {
    guard let rvalue = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0) else {
        return nil
    }
    return rvalue.takeRetainedValue() as? NSDictionary
}

func getProperties(_ service: io_service_t) -> NSDictionary? {
    var CFProps: Unmanaged<CFMutableDictionary>?
    guard kIOReturnSuccess == IORegistryEntryCreateCFProperties(service, &CFProps, kCFAllocatorDefault, 0),
          CFProps != nil else {
        return nil
    }
    return CFProps?.takeRetainedValue() as NSDictionary?
}

func sendBoolean(_ key: String, _ value: Bool, _ service: io_service_t) -> Bool {
    return (kIOReturnSuccess == IORegistryEntrySetCFProperty(service, key as CFString, value as CFBoolean))
}

func sendNumber(_ key: String, _ value: Int, _ service: io_service_t) -> Bool {
    return (kIOReturnSuccess == IORegistryEntrySetCFProperty(service, key as CFString, value as CFNumber))
}

func sendString(_ key: String, _ value: String, _ service: io_service_t) -> Bool {
    return (kIOReturnSuccess == IORegistryEntrySetCFProperty(service, key as CFString, value as CFString))
}

/// True when the driver exposes `key` as a usable value.
///
/// The driver reports a capability it cannot drive as the literal string
/// "unsupported" instead of a boolean, so a plain `as? Bool` cast is not
/// enough to tell "not available" from "turned off".
func isAvailable(_ key: String, _ props: NSDictionary) -> Bool {
    guard let value = props[key] else {
        return false
    }
    if let marker = value as? NSString {
        return marker != "unsupported"
    }
    return true
}

/// Ask the driver to re-run EC capability detection and return fresh properties.
///
/// On some firmware (e.g. Lenovo Ideapad) the EC is not yet responsive while
/// the driver is starting, so evaluating HALS / GBMD fails and capability
/// properties such as `PrimeKeyType`, `FnlockMode` or `AlwaysOnUSBMode` are
/// never published. Writing the `reset` property makes the driver evaluate
/// them again; the result is available immediately afterwards.
///
/// - Returns: refreshed driver properties, or nil when the write failed
func reloadCapability(_ service: io_service_t) -> NSDictionary? {
    guard sendBoolean("reset", true, service) else {
        return nil
    }
    return getProperties(service)
}
