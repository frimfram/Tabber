//
//  SettingsViewController.swift
//  tips
//
//  Created by Jean Ro on 12/14/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var percent1Label: UILabel!
    @IBOutlet weak var percent2Label: UILabel!
    
    @IBOutlet weak var percent3Label: UILabel!
    
    @IBOutlet weak var percent1Stepper: UIStepper!
    @IBOutlet weak var percent2Stepper: UIStepper!
    @IBOutlet weak var percent3Stepper: UIStepper!
    
    @IBOutlet weak var themePickerControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var storedValues = retrieveFromStore()
        percent1Label.text = "\(storedValues.percent1)%"
        percent2Label.text = "\(storedValues.percent2)%"
        percent3Label.text = "\(storedValues.percent3)%"
        
        percent1Stepper.value = Double(storedValues.percent1)
        percent2Stepper.value = Double(storedValues.percent2)
        percent3Stepper.value = Double(storedValues.percent3)
        
        themePickerControl.selectedSegmentIndex = storedValues.themeIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func stepper1(sender: UIStepper) {
        percent1Label.text = String(format: "%.0f%%", sender.value)
        saveToStore(Int(sender.value), key: "percent1")
    }

    @IBAction func stepper2(sender: UIStepper) {
        percent2Label.text = String(format: "%.0f%%", sender.value)
        saveToStore(Int(sender.value), key: "percent2")
    }
    
    
    @IBAction func stepper3(sender: UIStepper) {
        percent3Label.text = String(format: "%.0f%%", sender.value)
        saveToStore(Int(sender.value), key: "percent3")
    }
    
    @IBAction func themePicked(sender: AnyObject) {
        var index = themePickerControl.selectedSegmentIndex
        saveToStore(index, key: "theme")
    }
    
    @IBAction func backButtonClicked(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func saveToStore(value:Int, key:String) {
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(value, forKey:key)
        defaults.synchronize()
    }
    
    func retrieveFromStore() -> (percent1:Int, percent2:Int, percent3:Int, themeIndex: Int) {
        var defaults = NSUserDefaults.standardUserDefaults()
        var percent1 = defaults.integerForKey("percent1")
        var percent2 = defaults.integerForKey("percent2")
        var percent3 = defaults.integerForKey("percent3")
        var themeIndex = defaults.integerForKey("theme")
        var result = (percent1: percent1, percent2: percent2, percent3: percent3, themeIndex:themeIndex)
        
        return result
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
