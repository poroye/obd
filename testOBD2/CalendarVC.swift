//
//  CalendarVC.swift
//  testOBD2
//
//  Created by ธนัท แสงเพิ่ม on 7/2/2565 BE.
//

import UIKit
import FSCalendar
import AEOTPTextField
import RealmSwift

class CalendarVC: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var otpTextfield: AEOTPTextField!
    private var reCAPTCHAViewModel: ReCAPTCHAViewModel?
    
    var formatter = DateFormatter()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.locale = Locale(identifier: "th")
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.todayColor = .green
        calendar.allowsMultipleSelection = false
        
        otpTextfield.otpDelegate = self
        otpTextfield.configure(with: 6)
        
        let viewModel = ReCAPTCHAViewModel(
            siteKey: "6Ld5t2QeAAAAAK6Isb3DzErKMWK703GO0JHv6Orc",
            url: URL(string: "https://www.cdgs.co.th")!
        )
        viewModel.delegate = self
        let vc = ReCAPTCHAViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: vc)
        reCAPTCHAViewModel = viewModel
        present(nav, animated: true)
        
//        let obd2 = OBD2_BLE.sharedInstance
//        obd2.allcommand = []
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {   obd2.getEngineRPM() }
        
        let speed = realm.objects(Speed.self)
        print(speed)
    }
    
    class func initVC() -> CalendarVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "CalendarVC") as! CalendarVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let obd2 = OBD2_BLE.sharedInstance
        obd2.enableLoop = false
    }
    // MARK: - Navigation
}

extension CalendarVC : ReCAPTCHAViewModelDelegate {
    func didSolveCAPTCHA(token: String) {
        print("Token: \(token)")
    }
}

extension CalendarVC : FSCalendarDelegate , FSCalendarDataSource{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        formatter.dateFormat = "dd-MM-yyyy"
        print("date selected => \(formatter.string(from: date))")
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date().addingTimeInterval(24*60*60*45)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let eventDate = Date.parse("2565-02-10")
        return date == eventDate ? 1 : 0
    }
}

extension CalendarVC: AEOTPTextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        print("user input is = \(code)")
    }
}

extension Date {
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let gregorianCalendar = NSCalendar(calendarIdentifier: .gregorian)!

        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day

        let date = gregorianCalendar.date(from: dateComponents)!
        return date
    }

    static func parse(_ string: String, format: String = "yyyy-MM-dd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = NSTimeZone.default
        dateFormatter.dateFormat = format

        let date = dateFormatter.date(from: string)!
        return date
    }
}
