//
//  iPadsThatNeedAdjusting.swift
//  groovy
//
//  Created by Kyle Stokes on 8/2/18.
//  Copyright © 2018 Kyle Stokes. All rights reserved.
//

import Foundation
import DeviceKit


struct iPadsThatNeedAdjusting {
    static let noniPadPro12InchDevices = [Device.iPadMini2,Device.iPadMini3, Device.iPadMini4, Device.iPad5, Device.iPad6, Device.iPadAir, Device.iPadAir2, Device.iPadPro9Inch, Device.iPadPro10Inch, Device.simulator(Device.iPadPro10Inch), Device.simulator(Device.iPadPro9Inch), Device.simulator(Device.iPadAir), Device.simulator(Device.iPadAir2), Device.simulator(Device.iPad5), Device.simulator(Device.iPad6)]
    
    static let iPadPro12InchDevices = [Device.iPadPro12Inch, Device.iPadPro12Inch2, Device.simulator(Device.iPadPro12Inch), Device.simulator(Device.iPadPro12Inch2)]
}
