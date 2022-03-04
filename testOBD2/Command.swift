//
//  Command.swift
//  testOBD2
//
//  Created by ธนัท แสงเพิ่ม on 10/2/2565 BE.
//

import Foundation

enum Command: String {
    case set1
    case set2
    case set3
    case set4
    case set5
    case set6
    case set7
    case set8
    case set9
    case set10
    case set11
    case velocity
    case engineRPM
    
    init?(commandCode: String) {
        switch commandCode {
        case "010D":
            self = .velocity
        case "010C":
            self = .engineRPM
        default:
            return nil
        }
    }
    
    func getCommand() -> String{
        switch self{
        case .set1:
            return "ATZ"
        case .set2:
            return "ATE0"
        case .set3:
            return "ATL0"
        case .set4:
            return "ATS1"
        case .set5:
            return "ATAT0"
        case .set6:
            return "ATSP0"
        case .set7:
            return "ATH1"
        case .set8:
            return "0100"
        case .set9:
            return "0120"
        case .set10:
            return "0140"
        case .set11:
            return "ATH0"
        case .velocity:
            return "010D"
        case .engineRPM:
            return "010C"
        }
    }
    
    func getValue(dataStr: String) -> Int{
        switch self{
        case .velocity:
            let byteA = dataStr.split(separator: " ")[2]
            let speedValue = Int(byteA, radix: 16)!
            return speedValue
        case .engineRPM:
            let byteAB = dataStr.split(separator: " ")[2] + dataStr.split(separator: " ")[3]
            let rpmValue = Int(byteAB, radix: 16)! / 4
            return rpmValue
        case .set1:
            return 1
        case .set2:
            return 1
        case .set3:
            return 1
        case .set4:
            return 1
        case .set5:
            return 1
        case .set6:
            return 1
        case .set7:
            return 1
        case .set8:
            return 1
        case .set9:
            return 1
        case .set10:
            return 1
        case .set11:
            return 1
        }
    }
}
