//
//  IntervalsViewController.swift
//  Pitch Pro
//
//  Created by Quinton Woodmansee on 1/14/16.
//  Copyright © 2016 Quinton Woodmansee. All rights reserved.
//

import UIKit


extension UISegmentedControl {
    func goVertical() {
        self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        for segment in self.subviews {
            for segmentSubview in segment.subviews {
                if segmentSubview is UILabel {
                    (segmentSubview as! UILabel).transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
                }
            }
        }
    }
    
    func setFontSize(fontSize: CGFloat) {
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName: self.tintColor,
            NSFontAttributeName: UIFont.systemFontOfSize(fontSize, weight: UIFontWeightRegular)
        ]
        
        let boldTextAttributes: [NSObject : AnyObject] = [
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize, weight: UIFontWeightMedium),
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Highlighted)
        self.setTitleTextAttributes(boldTextAttributes, forState: .Selected)
        
    }
}


class IntervalsViewController: UIViewController {

    //base frequencies upon which all intervals will be decided.
    //TODO(quinton): Make this a dictionary instead of an array
    var frequencies: [String : Float] = [
        "C♮" : 16.35,
        "C#": 17.32,
        "D♮" : 18.35,
        "D#": 19.45,
        "E♮" : 20.60,
        "F♮" : 21.83,
        "F#": 23.12,
        "G♮" : 24.50,
        "G#": 25.96,
        "A♮" : 27.50,
        "A#": 29.14,
        "B♮" :30.87]

    //instruments which will play basic sine waves
    let myInstrumentBase = BasicSynth()
    let myInstrumentHarmony = BasicSynth()
    
    
    @IBOutlet weak var baseNoteSelection: UISegmentedControl!
    
    @IBOutlet weak var baseNoteAccidentalSelection: UISegmentedControl!
    
    @IBOutlet weak var intervalSlider: UISlider!
    
    @IBOutlet weak var intervalLabel: UILabel!
    
    @IBOutlet weak var tuningSystemSlider: UISlider!
    
    @IBOutlet weak var tuningSystemLabel: UILabel!
    
    @IBOutlet weak var fundamentalNoteSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var fundamentalQualitySegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var playSwitch: UISwitch!
    
    @IBOutlet weak var harmonicMelodicSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var intervalQualitySegmentedControl: UISegmentedControl!
    
    var myInterval: Int = 8 //note that this is number of keys, not number of steps
    var myIntervalQuality = 2; // 2 is maj/perf
    var myTuningSystem = 2
    
    var myFundamentalNote: String = "C"
    var myFundamentalQuality: String = "♮"
    var myFundamentalFrequency: Float = 261.63 // C♮4
    
    var myHarmonicFrequency : Float = 392.00 // G♮4
    var myIntervalPlayStyle = "Harmonic"
    
    //---------------------------------------------------------------

    @IBAction func doneButtonClicked(sender: UIButton) {
        myInstrumentBase.stop()
        myInstrumentHarmony.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //---------------------------------------------------------------

    @IBAction func harmonicMelodicSegmentedControlValueChanged(sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            myIntervalPlayStyle = "Harmonic"
            if (playSwitch.on) {
                myInstrumentBase.stop()
                myInstrumentHarmony.stop()
                delay(0.1) {
                    self.myInstrumentBase.play()
                    self.myInstrumentHarmony.play()
                
                }
            }
        }
            
        else {
            myIntervalPlayStyle = "Melodic"
            if (playSwitch.on) {
                myInstrumentBase.stop()
                myInstrumentHarmony.stop()
                //TODO(quinton): implement melodic playing
                delay(0.1) {
                    self.myInstrumentBase.playForDuration(1.0)
                }
                delay(1.0) {
                    if (self.playSwitch.on) {
                        self.myInstrumentHarmony.playForDuration(1.0)
                    }
                }
            }
        }

    }
    
    //---------------------------------------------------------------

    @IBAction func playSwitchChanged(sender: UISwitch) {
        
        if (playSwitch.on)
        {
            if (myIntervalPlayStyle == "Harmonic") {
                myInstrumentBase.play()
                myInstrumentHarmony.play()
            }
            else {
                //TODO(quinton): implement melodic playing
                myInstrumentBase.playForDuration(1.0)
                delay(0.9) {
                    if (self.playSwitch.on) {
                        self.myInstrumentHarmony.playForDuration(1.0)
                    }
                }
            }
        }
        else
        {
            myInstrumentBase.stop()
            myInstrumentHarmony.stop()
        }
        
        
    }
    
    //---------------------------------------------------------------
    
    @IBAction func intervalSliderValueChanged(sender: UISlider) {
        
        let sliderValue = Int(sender.value)
        
        switch sliderValue {
        case 1:
            myInterval = 0
            intervalLabel.text = "1st"
        case 2:
            myInterval = 2
            intervalLabel.text = "2nd"
        case 3:
            myInterval = 4
            intervalLabel.text = "3rd"
        case 4:
            myInterval = 5
            intervalLabel.text =
                "4th"
        case 5:
            myInterval = 7
            intervalLabel.text = "5th"
        case 6:
            myInterval = 9
            intervalLabel.text = "6th"
        case 7:
            myInterval = 11
            intervalLabel.text = "7th"
        case 8:
            myInterval = 12
            intervalLabel.text = "Octave"
        default:
            myInterval = 0;
            intervalLabel.text = "Error"
        }
        
        
        determineEqualTemperamentHarmonicFrequency()
        myInstrumentHarmony.frequency.value = myHarmonicFrequency
        
    }
    
    //---------------------------------------------------------------

    @IBAction func intervalQualityValueChanged(sender: UISegmentedControl) {
        
        myIntervalQuality = sender.selectedSegmentIndex
        
        determineEqualTemperamentHarmonicFrequency()
        myInstrumentHarmony.frequency.value = myHarmonicFrequency
        
        }
    //---------------------------------------------------------------

    @IBAction func tuningSystemSliderValueChanged(sender: UISlider) {
        
        myTuningSystem = Int(sender.value)
        
        switch myTuningSystem {
        case 0:
            tuningSystemLabel.text = "Just Intonation"
        case 1:
            tuningSystemLabel.text = "Pythagorean"
        case 2:
            tuningSystemLabel.text = "Equal Temperament"
        case 3:
            tuningSystemLabel.text = "Well Temperament"
        case 4:
            tuningSystemLabel.text = "Meantone Temperament"
        default:
            tuningSystemLabel.text = "Error"
        }
        
    }

    //---------------------------------------------------------------

    @IBAction func fundamentalNoteChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            myFundamentalNote = "C"
        case 1:
            myFundamentalNote = "D"
        case 2:
            myFundamentalNote = "E"
        case 3:
            myFundamentalNote = "F"
        case 4:
            myFundamentalNote = "G"
        case 5:
            myFundamentalNote = "A"
        case 6:
            myFundamentalNote = "B"
        default:
            myFundamentalNote = "ERROR"
            
        }
        
        //update fundmamental frequency
        determineFundamentalFrequency()
        
        //update interval frequency
        determineIntervalFrequency()
        
        //set the fundamental instrument's pitch
        myInstrumentBase.frequency.value = myFundamentalFrequency
        
        //set the harmonic instrument's pitch
        myInstrumentHarmony.frequency.value = myHarmonicFrequency
        
    }
    
    //---------------------------------------------------------------

    func determineIntervalFrequency() {
        
        //if we are in equal temperament
        if (myTuningSystem == 2) {
            determineEqualTemperamentHarmonicFrequency()
        }
        
        
    }
    
    //---------------------------------------------------------------

    func determineFundamentalFrequency() {
        
        myFundamentalFrequency = frequencies[String(myFundamentalNote + myFundamentalQuality)]! * Float(pow(Double(2),4))


    }

    //---------------------------------------------------------------

    func determineEqualTemperamentHarmonicFrequency() {
        
        var adjustedInterval: Int = myInterval
        
        // if interval is diminished
        if (myIntervalQuality == 0) {
            adjustedInterval -= 2
        }
            // if interval is minor
        else if (myIntervalQuality == 1) {
            adjustedInterval -= 1
        }
            // if interval is augmented
        else if (myIntervalQuality == 3) {
            adjustedInterval += 1
        }
        
        myHarmonicFrequency = myFundamentalFrequency * pow( pow(2, (1/12)), Float(adjustedInterval))
        
    }
    
    //---------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        //rotate the base note selection
        //baseNoteAccidentalSelection.setFontSize(20)
        baseNoteSelection.goVertical()
        baseNoteAccidentalSelection.goVertical()

        //set up two instruments
        AKOrchestra.addInstrument(myInstrumentBase)
        AKOrchestra.addInstrument(myInstrumentHarmony)
        
        //set the default value of labels
        intervalLabel.text = "5th"
        tuningSystemLabel.text = "Equal Temperament"
        
        //TODO(quinton) set the default value of current note name and frequecy
        myInstrumentBase.frequency.value = myFundamentalFrequency
        
        myInstrumentHarmony.frequency.value = myHarmonicFrequency
        
    }

    //---------------------------------------------------------------

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    //---------------------------------------------------------------
    //Simple delay function to dispatch after a certain amount of time
    //got from matt at http://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift/24318861#24318861
    
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    //---------------------------------------------------------------

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
