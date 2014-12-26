//
//  TabberViewController.swift
//  tips
//
//  Created by Jean Ro on 12/24/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class TabberViewController: UIViewController {

    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var billField: UITextField!
    
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var totalTwoPeople: UILabel!
    
    @IBOutlet weak var totalThreePeople: UILabel!
    
    @IBOutlet weak var totalFourPeople: UILabel!
    
    @IBOutlet weak var tipControl: UISegmentedControl!
    
    @IBOutlet weak var bottomView: UIView!
    
    var tipPercentages = [18, 20, 22]
    
    var originalBillFieldRec : CGRect = CGRectZero
    var originalBottomViewRec : CGRect = CGRectZero
    var originalTipControlRec : CGRect = CGRectZero
    var currencyFormatter : NSNumberFormatter = NSNumberFormatter()
    
    let backgroundColors: [UIColor] =
        [ UIColor(red: 0, green: 128/256, blue: 64/256, alpha: 1),
          UIColor(red: 1, green: 1, blue: 102/256, alpha: 0.8)]
    let textColors: [UIColor] =
        [ UIColor(red: 1, green: 1, blue: 1, alpha: 0.6),
          UIColor(red: 0, green: 128/256, blue: 0, alpha: 1)]

    let savedBillAmountKey = "Tabber_SAVED_BILL_AMOUNT"
    let savedTimestampKey = "Tabber_SAVED_BILL_TIMESTAMP"
    
    override func viewDidLoad() {
        println(__FUNCTION__)
        
        super.viewDidLoad()
        currencyFormatter.numberStyle = .CurrencyStyle
        currencyFormatter.locale = NSLocale.currentLocale()
        
        //set up to get notified when application enters background
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        //initialize the bill field with recently used value if applicable
        let defaults = NSUserDefaults.standardUserDefaults()
        let storedBill = defaults.objectForKey(savedBillAmountKey) as String?
        let storedTimestamp = defaults.objectForKey(savedTimestampKey) as NSDate?
        self.billField.text = nil
        if storedTimestamp != nil {
            let elapsedTime = NSDate().timeIntervalSinceDate(storedTimestamp!)
            let elapsedTimeInMins = elapsedTime / 60
            if elapsedTimeInMins < 10 {  //if the app restarted 10mins or less from the last used, show the stored bill amount
                self.billField.text = storedBill
            }
        }
    }
    
    func applicationDidEnterBackground() {
        println(__FUNCTION__)
        let latestBill = self.billField.text
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(latestBill, forKey:savedBillAmountKey)
        defaults.setObject(NSDate(), forKey:savedTimestampKey)
        defaults.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onEditingChanged(sender: AnyObject) {
        
        if billField.text.isEmpty {
            hideViews(sender is NSNull)
        }else{
        
            var tipPercentage = tipPercentages[tipControl.selectedSegmentIndex]
            
            var billAmount = (billField.text as NSString).doubleValue
            var tip = (billAmount * Double(tipPercentage)) / 100
            var total = billAmount + tip
            
            tipLabel.text = self.currencyFormatter.stringFromNumber(tip)
            totalLabel.text = self.currencyFormatter.stringFromNumber(total)
            totalTwoPeople.text = self.currencyFormatter.stringFromNumber(total/2)
            totalThreePeople.text = self.currencyFormatter.stringFromNumber(total/3)
            totalFourPeople.text = self.currencyFormatter.stringFromNumber(total/4)
            if self.bottomView.hidden {
                showViews()
            }
        }
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
        
        originalBillFieldRec = billField.frame
        originalBottomViewRec = self.bottomView.frame
        originalTipControlRec = self.tipControl.frame
        
        onEditingChanged(NSNull)
        
        //change the color based on the selected theme
        self.bottomView.backgroundColor = self.backgroundColors[savedValues.themeIndex]
        for aView in self.bottomView.subviews {
            if aView is UILabel {
                (aView as UILabel).textColor = self.textColors[savedValues.themeIndex]
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if billField.text.isEmpty && billField.frame.origin.y < 150 {
            hideViews(true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.billField.becomeFirstResponder()
    }
    
    func retrieveSavedPercentagesFromStore() -> (percent1:Int, percent2:Int, percent3:Int, themeIndex:Int) {
        var defaults = NSUserDefaults.standardUserDefaults()
        
        let appUsedBeforeObj:AnyObject? = defaults.objectForKey("openedBefore")
        var themeIndex = 0
        
        if appUsedBeforeObj != nil {
            for index in 0...2 {
                tipPercentages[index] = defaults.integerForKey("percent\(index+1)")
            }
            themeIndex = defaults.integerForKey("theme")
        }else{
            
            for index in 0...2 {
                defaults.setInteger(tipPercentages[index], forKey: "percent\(index+1)")
            }
            defaults.setInteger(0, forKey: "theme")
            defaults.setObject("YES", forKey: "openedBefore")
            defaults.synchronize()
        }
        
        return (percent1: tipPercentages[0], percent2: tipPercentages[1], percent3: tipPercentages[2], themeIndex: themeIndex)
    }
    
    func hideViews(skipanimate: Bool) {
        
        var diff = self.originalBottomViewRec.minY - self.originalTipControlRec.maxY

        self.billField.alpha = 0
        
        if skipanimate {
            self.bottomView.hidden = true
            self.tipControl.hidden = true
            self.tipControl.frame = CGRect(x: self.originalTipControlRec.origin.x, y: self.view.frame.maxY , width: self.originalTipControlRec.width, height: self.originalTipControlRec.height)
            self.bottomView.frame = CGRect(x: self.originalBottomViewRec.origin.x, y: self.tipControl.frame.maxY + diff , width: self.originalBottomViewRec.width, height: self.originalBottomViewRec.height)
            self.billField.frame = CGRect(x: self.originalBillFieldRec.origin.x, y: 160, width: self.originalBillFieldRec.width, height: self.originalBillFieldRec.height)
            self.billField.alpha = 1
            
        }else if !(self.bottomView.hidden && self.tipControl.hidden) {
        
            UIView.animateWithDuration(0.4, animations: {
                self.tipControl.frame = CGRect(x: self.originalTipControlRec.origin.x, y: self.view.frame.maxY , width: self.originalTipControlRec.width, height: self.originalTipControlRec.height)
                self.bottomView.frame = CGRect(x: self.originalBottomViewRec.origin.x, y: self.tipControl.frame.maxY + diff , width: self.originalBottomViewRec.width, height: self.originalBottomViewRec.height)
                self.billField.alpha = 1
                self.billField.frame = CGRect(x: self.originalBillFieldRec.origin.x, y: 160, width: self.originalBillFieldRec.width, height: self.originalBillFieldRec.height)
                
                }, completion: {
                    (value: Bool) in
                    self.bottomView.hidden = true
                    self.tipControl.hidden = true
            } )
        }
        
    }
    
    func showViews() {
        self.bottomView.hidden = false
        self.tipControl.hidden = false
        
        UIView.animateWithDuration(0.4, animations: {
            self.billField.frame = self.originalBillFieldRec
            self.tipControl.frame = self.originalTipControlRec
            self.bottomView.frame = self.originalBottomViewRec
        })
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
