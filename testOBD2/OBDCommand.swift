//
//  OBDCommand.swift
//  testOBD2
//
//  Created by ธนัท แสงเพิ่ม on 2/2/2565 BE.
//

import Foundation

class OBDCommandC {
    var tag: String = ""
    var name: String = ""
    var mode: String = ""
    var pid: String = ""
    var defaultUnit: String = ""
    var handler: () -> String = {
        return ""
    }
}

protocol OBDCommandI {
    var tag: String { get set }
    var name: String { get set }
    var mode: String { get set }
    var pid: String { get set }
    var defaultUnit: String { get set }
    var handler: String { get set }
}

//class speedCommand: OBDCommandI {
//    var tag: String = "SPEED"
//    var name: String = "Vehicle Speed"
//    var mode: String = "01"
//    var pid: String = "0D"
//    var defaultUnit: String = "Km/h"
//    var handler: String = { IntDataString in
//        return ""
//    }(_)
//}




