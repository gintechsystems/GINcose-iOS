//
//  HomeViewController.swift
//  GINcose
//
//  Created by Joe Ginley on 3/9/16.
//  Copyright © 2016 GINtech Systems. All rights reserved.
//

import UIKit
import RealmSwift

class HomeViewController: UIViewController, TransmitterDelegate {

    @IBOutlet var glucoseLabel :UILabel!
    
    @IBOutlet var glucoseLoading :UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        appDel.defaultTransmitter.stayConnected = UserDefaults.standard.stayConnected
        appDel.defaultTransmitter.delegate = self
        
        // Check if there is a most recent glucose level available.
        let realm = try! Realm()
        let latestGlucose = realm.objects(GlucoseInfo.self).last
        
        if (latestGlucose != nil) {
            self.glucoseLoading.isHidden = true
            self.glucoseLabel.text = String(latestGlucose!.glucose)
        }
        
        /*appDel.delay(0.5) { () -> () in
            self.testGlucose()
            //self.testSensor()
        }*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func transmitter(_ transmitter: Transmitter, didRead glucose: Glucose) {
        NSLog("\(glucose)")
        
        DispatchQueue.main.async { () -> Void in
            if (self.glucoseLabel.text == "???") {
                self.glucoseLoading.isHidden = true
            }
            
            self.glucoseLabel.text = NumberFormatter.localizedString(from: NSNumber(value: Int16(glucose.glucose) as Int16), number: .none)
            
            let latestGlucose = GlucoseInfo()
            latestGlucose.id = Int(Date().timeIntervalSince1970)
            latestGlucose.glucose = Int(glucose.glucose)
            latestGlucose.timestamp = appDel.glucoseDateFormatter.string(from: Date(timeIntervalSinceNow: TimeInterval(Double(glucose.glucoseMessage.timestamp) / 1000)))
            
            //NSLog("\(latestGlucose.timestamp)")
            
            //Update our local db with the latest glucose level.
            let realm = try! Realm()
            try! realm.write { () -> Void in
                realm.add(latestGlucose)
            }
        }
    }
    
    func transmitter(_ transmitter: Transmitter, didError error: Swift.Error) {
        NSLog("\(error)")
        
        DispatchQueue.main.async { () -> Void in
            self.glucoseLabel.text = "???"
            self.glucoseLoading.isHidden = false
        }
    }
    
    func transmitter(_ transmitter: Transmitter, didReadUnknownData data: Data) {
        NSLog("\(data)")
        
        DispatchQueue.main.async { () -> Void in
            self.glucoseLabel.text = "???"
            self.glucoseLoading.isHidden = false
        }
    }
    
    // Run a test glucose result.
    func testGlucose() {
        let message = GlucoseRxMessage(data: Data(hexadecimalString: "3100680a00008a715700cc0006ffc42a")!)!
        let glucose = Glucose(glucoseMessage: message, timeMessage: TransmitterTimeRxMessage(data: Data(hexadecimalString: "2500470272007cff710001000000fa1d")!)!, activationDate: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2017, month: 3, day: 1))!)
        
        transmitter(appDel.defaultTransmitter, didRead: glucose)
    }
    
    // Run a test trend result.
    func testTrend() {
        let message = GlucoseRxMessage(data: Data(hexadecimalString: "31006f0a0000be7957007a0006e4818d")!)!
        let glucose = Glucose(glucoseMessage: message, timeMessage: TransmitterTimeRxMessage(data: Data(hexadecimalString: "2500470272007cff710001000000fa1d")!)!, activationDate: Calendar(identifier: .gregorian).date(from: DateComponents(year: 2017, month: 3, day: 1))!)
        
        transmitter(appDel.defaultTransmitter, didRead: glucose)
    }
    
    // Run a test sensor result.
    /*func testSensor() {
        let sensorMessage = SensorRxMessage(data: Data(hexadecimalString: "2f00a1b27400600b030020000300560f")!)!
        
        transmitter(appDel.defaultTransmitter, didRead: sensorMessage)
    }*/
}
