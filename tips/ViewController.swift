//
//  ViewController.swift
//  tips
//
//  Created by Jean Ro on 12/14/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var billField: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    var tipPercentages = [18, 20, 22]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tipLabel.text = "$0.00"
        totalLabel.text = "$0.00"
        println("view did load")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onEditingChanged(sender: AnyObject) {
        
        var tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
        
        var billAmount = (billField.text as NSString).doubleValue
        var tip = (billAmount * Double(tipPercentage)) / 100
        var total = billAmount + tip
        
        tipLabel.text = String(format: "$%.2f", tip)
        totalLabel.text = String(format: "$%.2f", total)
    }

    @IBAction func onTap(sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var savedValues = retrieveSavedPercentagesFromStore()
        tipControl.setTitle("\(savedValues.percent1)%", forSegmentAtIndex: 0)
        tipControl.setTitle("\(savedValues.percent2)%", forSegmentAtIndex: 1)
        tipControl.setTitle("\(savedValues.percent3)%", forSegmentAtIndex: 2)
        
        onEditingChanged(NSNull())
        
        println("view will appear")
    }
    
    func retrieveSavedPercentagesFromStore() -> (percent1:Int, percent2:Int, percent3:Int) {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        let appUsedBeforeObj:AnyObject? = defaults.objectForKey("openedBefore")
        
        if appUsedBeforeObj != nil {
            for index in 0...2 {
               tipPercentages[index] = defaults.integerForKey("percent\(index+1)")
            }

        }else{
            
            for index in 0...2 {
               defaults.setInteger(tipPercentages[index], forKey: "percent\(index+1)")
            }
            defaults.setObject("YES", forKey: "openedBefore")
            defaults.synchronize()
        }
        
        return (percent1: tipPercentages[0], percent2: tipPercentages[1], percent3: tipPercentages[2])
    }
    
}

