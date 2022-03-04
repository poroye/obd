//
//  NotSleepVC.swift
//  testOBD2
//
//  Created by ธนัท แสงเพิ่ม on 31/1/2565 BE.
//

import UIKit
import FittedSheets


class NotSleepVC: UIViewController {
    
    @IBOutlet weak var niddleImageView: UIImageView!
    @IBOutlet weak var datePick: UIDatePicker!
    
    var currentDeviceOrientation: UIDeviceOrientation = .unknown
    
    var valueCheck: Int = 0 {
        didSet {
            niddleImageView.transform = CGAffineTransform(rotationAngle: CGFloat(valueCheck) * .pi / 180)
        }
    }
    
    class func initVC() -> NotSleepVC {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "NotSleepVC") as! NotSleepVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        niddleImageView.layer.anchorPoint = CGPoint(x: 0.5, y: 1)
        niddleImageView.isHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
        
        let controller = BotSheetVC()

        let sheetController = SheetViewController(controller: controller)

        self.present(sheetController, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            UIView.animate(withDuration: 1) {
                self.valueCheck = 30
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            UIView.animate(withDuration: 1) {
                self.valueCheck = 60
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
            UIView.animate(withDuration: 1) {
                self.valueCheck = 90
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.view.backgroundColor = .gray
            UIView.animate(withDuration: 1) {
                self.valueCheck = 120
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func DateChange(_ sender: UIDatePicker) {
        print("date change to \(datePick.date)")
        datePick.minimumDate = datePick.date
    }
    
    // MARK: - Navigation

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { context in
            if let interfaceOrientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation {
                if interfaceOrientation.isLandscape {
                    print("rotate")
                    self.niddleImageView.isHidden = false
                    self.datePick.isHidden = true
                } else if interfaceOrientation.isPortrait {
                    print("normal")
                    self.niddleImageView.isHidden = true
                    self.datePick.isHidden = false
                }
            }
        })
    }
}

