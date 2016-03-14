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
        appDel.defaultTransmitter.stayConnected = true
        appDel.defaultTransmitter.delegate = self
        
        // Check if there is a most recent glucose level available.
        let realm = try! Realm()
        let latestGlucose = realm.objects(GlucoseInfo).last
        
        if (latestGlucose != nil) {
            self.glucoseLoading.hidden = true
            self.glucoseLabel.text = String(latestGlucose!.glucose)
        }
        
        appDel.delay(0.5) { () -> () in
            //self.testGlucose()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func transmitter(transmitter: Transmitter, didReadGlucose glucose: GlucoseRxMessage) {
        NSLog("New Glucose: \(glucose)")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            if (self.glucoseLabel.text == "???") {
                self.glucoseLoading.hidden = true
            }
            
            self.glucoseLabel.text = NSNumberFormatter.localizedStringFromNumber(NSNumber(short: Int16(glucose.glucose)), numberStyle: .NoStyle)
            
            let latestGlucose = GlucoseInfo()
            latestGlucose.id = Int(NSDate().timeIntervalSince1970)
            latestGlucose.glucose = Int(glucose.glucose)
            latestGlucose.timestamp = appDel.glucoseDateFormatter.stringFromDate(NSDate(timeIntervalSinceNow: NSTimeInterval(Double(glucose.timestamp) / 1000)))
            
            NSLog("\(latestGlucose.timestamp)")
            
            let realm = try! Realm()
            try! realm.write { () -> Void in
                realm.add(latestGlucose)
            }
        }
    }
    
    func transmitter(transmitter: Transmitter, didReadSensor sensor: SensorRxMessage) {
        NSLog("\(sensor)")
    }
    
    func transmitter(transmitter: Transmitter, didError error: ErrorType) {
        NSLog("\(error)")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.glucoseLabel.text = "???"
            self.glucoseLoading.hidden = false
        }
    }
    
    //Run a test blood sugar result.
    func testGlucose() {
        let glucoseMessage = GlucoseRxMessage(data: NSData(hexadecimalString: "3100680a00008a715700cc0006ffc42a")!)!
        
        transmitter(appDel.defaultTransmitter, didReadGlucose: glucoseMessage)
    }
    
}
