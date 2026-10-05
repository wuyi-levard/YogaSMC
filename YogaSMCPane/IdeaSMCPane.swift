//
//  IdeaSMCPane.swift
//  YogaSMCPane
//
//  Created by Zhen on 12/9/20.
//  Copyright © 2020 Zhen. All rights reserved.
//

import AppKit
import Foundation

extension YogaSMCPane {
    @IBAction func vFnKeySet(_ sender: NSButton) {
        if !sendBoolean("FnlockMode", vFnKeyRadio.state == .on, service) {
            vFnKeyRadio.state = getBoolean("FnlockMode", service) ? .on : .off
        }
    }

    @IBAction func vAlwaysOnUSBModeSet(_ sender: NSButton) {
        if !sendBoolean("AlwaysOnUSBMode", vAlwaysOnUSBMode.state == .on, service) {
            vAlwaysOnUSBMode.state = getBoolean("AlwaysOnUSBMode", service) ? .on : .off
        }
    }

    @IBAction func vConservationModeSet(_ sender: NSButton) {
        if !sendBoolean("ConservationMode", vConservationMode.state == .on, service) {
            vConservationMode.state = getBoolean("ConservationMode", service) ? .on : .off
        }
    }

    func updateIdeaBattery(_ dict: NSDictionary) {
        vBatteryID.stringValue = dict["ID"] as? String ?? paneLocalizedString("Unknown")
        vCycleCount.stringValue = dict["Cycle count"] as? String ?? paneLocalizedString("Unknown")
        vBatteryTemperature.stringValue = dict["Temperature"] as? String ?? paneLocalizedString("Unknown")
        vMfgDate.stringValue = dict["Manufacture date"] as? String ?? paneLocalizedString("Unknown")
    }

    // Capability rows are plain labels carrying an Interface Builder
    // identifier that names the Capability key they stand for, so a row is
    // added by putting a label in the nib and publishing the key in the
    // driver -- no outlet and no per-row code.
    func updateIdeaCap(_ dict: NSDictionary) {
        guard let root = ideaViewItem.view else { return }
        var queue: [NSView] = [root]
        while let v = queue.popLast() {
            queue.append(contentsOf: v.subviews)
            guard let tf = v as? NSTextField,
                  let key = tf.identifier?.rawValue,
                  let val = dict[key] else { continue }
            if let on = val as? Bool {
                tf.textColor = on ? NSColor.systemGreen : NSColor.systemGray
            } else if let text = val as? String {
                tf.toolTip = text
                tf.textColor = text.hasPrefix("Unknown") ? NSColor.systemGray : NSColor.systemGreen
            }
        }
    }

    func updateIdea(_ props: NSDictionary) {
        if let val = props["PrimeKeyType"] as? NSString {
            vFnKeyRadio.title = val as String
            if isAvailable("FnlockMode", props), let val = props["FnlockMode"] as? Bool {
                vFnKeyRadio.isEnabled = true
                vFxKeyRadio.isEnabled = true
                vFnKeyRadio.state = val ? .on : .off
                vFxKeyRadio.state = val ? .off : .on
            } else {
                vFnKeyRadio.isEnabled = false
                vFxKeyRadio.isEnabled = false
            }
        } else {
            vFnKeyRadio.title = paneLocalizedString("Unknown")
        }

        if isAvailable("AlwaysOnUSBMode", props), let val = props["AlwaysOnUSBMode"] as? Bool {
            vAlwaysOnUSBMode.state = val ? .on : .off
            vAlwaysOnUSBMode.isEnabled = true
        }

        if isAvailable("ConservationMode", props), let val = props["ConservationMode"] as? Bool {
            vConservationMode.state = val ? .on : .off
            vConservationMode.isEnabled = true
        }

        if isAvailable("RapidChargeMode", props), let val = props["RapidChargeMode"] as? Bool {
            vRapidChargeMode.state = val ? .on : .off
            vRapidChargeMode.isEnabled = true
        }

        if let dict = props["Battery 0"] as? NSDictionary {
            updateIdeaBattery(dict)
        }

        if let dict = props["Capability"] as? NSDictionary {
            updateIdeaCap(dict)
        }
    }
}
