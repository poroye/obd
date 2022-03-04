//
//  ViewController.swift
//  testOBD2
//
//  Created by ธนัท แสงเพิ่ม on 26/1/2565 BE.
//

import UIKit
import Charts
import TinyConstraints
import RealmSwift

class ViewController: UIViewController {

    @IBOutlet weak var engineLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var testView: UIView!
    
    let yValue: [ChartDataEntry] = [
        ChartDataEntry(x: 0.0, y: 0.9),
        ChartDataEntry(x: 1.0, y: 32.0),
        ChartDataEntry(x: 2.0, y: 42.0),
        ChartDataEntry(x: 3.0, y: 56.2),
        ChartDataEntry(x: 4.0, y: 120.0),
        ChartDataEntry(x: 5.0, y: 80.2),
        ChartDataEntry(x: 6.0, y: 90.25),
        ChartDataEntry(x: 7.0, y: 50.3),
        ChartDataEntry(x: 8.0, y: 20.2),
        ChartDataEntry(x: 9.0, y: 0.0)
    ]
    
    lazy var lineChartView: LineChartView = {
        let chartView = LineChartView()
        return chartView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testView.addSubview(lineChartView)
        lineChartView.centerInSuperview()
        lineChartView.width(to: testView)
        lineChartView.height(to: testView)
        setData()
        
//        let obd2 = OBD2_BLE.sharedInstance
//        obd2.enableLoop = true
//        obd2.allcommand = [13,12]
//        delayOBD2(bt: obd2)
        
        
//        updateLabel(bt: obd2)
        
        let realmV = try! Realm()
        let spObj = realmV.objects(Speed.self)

        let token = spObj.observe { change in
            print(change)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppUtility.lockOrientation(.portrait)
        let obd2 = OBD2_BLE.sharedInstance
        obd2.enableLoop = true
//        obd2.mainCommand = [.engineRPM]
//        delayOBD2(bt: obd2)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppUtility.lockOrientation(.all)
    }
    
    @IBAction func notSleepPressed(_ sender: UIButton) {
        navigationController?.pushViewController(NotSleepVC.initVC(), animated: true)
    }
    @IBAction func calendarPressed(_ sender: UIButton) {
        navigationController?.pushViewController(CalendarVC.initVC(), animated: true)
    }
    
    func delayOBD2(bt: OBD2_BLE) {
//        DispatchQueue.global(qos: .userInitiated).asyncA {
//            bt.getEngineRPM()
//        }
    }

    @IBAction func sharedPressed(_ sender: UIButton) {
        let testImage = UIImage(view: testView)
        let activityVC = UIActivityViewController(activityItems: [testImage], applicationActivities: nil)
           activityVC.popoverPresentationController?.sourceView = self.view
           self.present(activityVC, animated: true, completion: nil)
    }
    
}

extension ViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    func setData() {
        let set1 = LineChartDataSet(entries: yValue, label: "speed")
        let data = LineChartData(dataSets: [set1])
        
        lineChartView.data = data
    }
}

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}

