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
    let frequencies: [String : Double] = [
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
    
    //ratios to find frequencies in just intonation
    //TODO(quinton): make this go from -13 to 13, to account for augmented octaves up and down.

    let justRatios: [Int : Double] = [
        -12 : Double(1.0/2.0),
        -11 : Double(8.0/15.0),
        -10 : Double(5.0/9.0),
        -9  : Double(3.0/5.0),
        -8  : Double(5.0/8.0),
        -7  : Double(2.0/3.0),
        -6  : Double(32.0/45.0),
        -5  : Double(3.0/4.0),
        -4  : Double(4.0/5.0),
        -3  : Double(5.0/6.0),
        -2  : Double(8.0/9.0),
        -1  : Double(24.0/25.0),
        0   : Double(1.0),
        1   : Double(25.0/24.0),
        2   : Double(9.0/8.0),
        3   : Double(6.0/5.0),
        4   : Double(5.0/4.0),
        5   : Double(4.0/3.0),
        6   : Double(45.0/32.0),
        7   : Double(3.0/2.0),
        8   : Double(8.0/5.0),
        9   : Double(5.0/3.0),
        10  : Double(9.0/5.0),
        11  : Double(15.0/8.0),
        12  : Double(2.0)]

    let pythagreanRatios: [Int: Double] = [
        -12 : Double(1.0/2.0),
        -11 : Double(128.0/243.0), //M7D
        -10 : Double(9.0/16.0), //m7D
        -9  : Double(16.0/27.0), //M7D
        -8  : Double(81.0/128.0), //m6D
        -7  : Double(2.0/3.0), //P5D
        -6  : Double(512.0/729.0), //Aug4D
        -5  : Double(3.0/4.0), //P4D
        -4  : Double(64.0/81.0), //M3D
        -3  : Double(27.0/32.0), //m3D
        -2  : Double(8.0/9.0), //M2D
        -1  : Double(243.0/256.0), //m2D
        0   : Double(1.0),
        1   : Double(256.0/243.0), //m2
        2   : Double(9.0/8.0), //M2
        3   : Double(32.0/27.0), //m3
        4   : Double(81.0/64.0), //M3
        5   : Double(4.0/3.0), //P4
        6   : Double(729.0/512.0), //Aug4
        7   : Double(3.0/2.0), //P5
        8   : Double(128.0/81.0), //m6
        9   : Double(27.0/16.0), //M6
        10  : Double(16.0/9.0), //m7
        11  : Double(243.0/128.0), //M7
        12  : Double(2.0)] //Oct

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
    
    @IBOutlet weak var intervalDirectionSegmentedControl: UISegmentedControl!
    
    
    var myInterval: Int = 8 //note that this is number of keys, not number of steps
    var myIntervalQuality = 2; // 2 is maj/perf
    var myIntervalDirection = 0; //0 is ascending, 1 is descending
    var myTuningSystem = 2
    
    var myFundamentalNote: String = "C"
    var myFundamentalQuality: String = "♮"
    var myFundamentalFrequency: Double = 261.63 // C♮4
    
    var myHarmonicFrequency : Double = 392.00 // G♮4
    var myIntervalPlayStyle = "Harmonic"
    
    //---------------------------------------------------------------

    @IBAction func doneButtonClicked(sender: UIButton) {
        myInstrumentBase.stop()
        myInstrumentHarmony.stop()
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    //---------------------------------------------------------------

    @IBAction func harmonicMelodicSegmentedControlValueChanged(sender: UISegmentedControl) {
        
        myInstrumentBase.stop()
        myInstrumentHarmony.stop()
        
        if (sender.selectedSegmentIndex == 0) {
            myIntervalPlayStyle = "Harmonic"

            if (playSwitch.on) {
                
                //wait so the instruments have time to completely stop
                delay(0.1) {
                    self.myInstrumentBase.play()
                    self.myInstrumentHarmony.play()
                }
            }
        }
            
        else {
            myIntervalPlayStyle = "Melodic"
            if (playSwitch.on) {

                //wait so the instruments have time to completely stop
                delay(0.2) {
                    self.playMelodicInterval()
                }

            }
        }

    }
    
    //---------------------------------------------------------------

    @IBAction func playSwitchChanged(sender: UISwitch) {
        
        myInstrumentHarmony.frequency.value = Float(myHarmonicFrequency)

        if (playSwitch.on)
        {
            if (myIntervalPlayStyle == "Harmonic") {
                myInstrumentBase.play()
                myInstrumentHarmony.play()
            }
            else {
                playMelodicInterval()
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
        
        
        determineIntervalFrequency()
        
    }
    
    //---------------------------------------------------------------

    @IBAction func intervalQualityValueChanged(sender: UISegmentedControl) {
        
        myIntervalQuality = sender.selectedSegmentIndex
        
        determineIntervalFrequency()
        myInstrumentHarmony.frequency.value = Float(myHarmonicFrequency)
        
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
        /*
        case 3:
            tuningSystemLabel.text = "Well Temperament"
        case 4:
            tuningSystemLabel.text = "Meantone Temperament"
        */
        default:
            tuningSystemLabel.text = "Error"
        }
        
        
        determineIntervalFrequency()
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
        myInstrumentBase.frequency.value = Float(myFundamentalFrequency)
        
        //set the harmonic instrument's pitch
        myInstrumentHarmony.frequency.value = Float(myHarmonicFrequency)
        
    }
    
    //---------------------------------------------------------------

    @IBAction func intervalDirectionChanged(sender: AnyObject) {
        
        myIntervalDirection = sender.selectedSegmentIndex
        //determine the new frequency since we are now going another direction
        determineIntervalFrequency()
    }
    
    //---------------------------------------------------------------
    func playMelodicInterval() {
        
        myInstrumentBase.playForDuration(1.0)
        delay(0.9) {
            if (self.playSwitch.on) {
                self.myInstrumentHarmony.playForDuration(1.0)
            }
        }
        
    }
    //---------------------------------------------------------------
    func determineIntervalFrequency() {
        
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
        
        //if descending
        if myIntervalDirection == 1 {
            
            //subtract 12 to bring the interval down an octave
            adjustedInterval -= 12
            
        }

        
        
        //if we are in equal temperament
        switch myTuningSystem {
            
        case 0: //just intonation
            determineJustIntonationHarmonicFrequency(adjustedInterval)
            
        case 1: //Pythagrean 
            determinePythagoreanHarmonicFrequency(adjustedInterval)
        
        case 2: //equal temperament
            determineEqualTemperamentHarmonicFrequency(adjustedInterval)
    
        default:
            determineEqualTemperamentHarmonicFrequency(adjustedInterval)
        
        }
        
        myInstrumentHarmony.frequency.value = Float(myHarmonicFrequency)
        
    }
    
    //---------------------------------------------------------------

    func determineFundamentalFrequency() {
        
        myFundamentalFrequency = frequencies[String(myFundamentalNote + myFundamentalQuality)]! * pow(Double(2),4)


    }

    //---------------------------------------------------------------

    func determineEqualTemperamentHarmonicFrequency(adjustedInterval: Int) {
        
        //equal temperament frequency equation: https://en.wikipedia.org/wiki/Equal_temperament
        //                                      (section: Calculating absolute frequencies)
        myHarmonicFrequency = myFundamentalFrequency * pow(pow(2, (1/12)), Double(adjustedInterval))
        
    }
    
    //---------------------------------------------------------------
    
    func determineJustIntonationHarmonicFrequency(adjustedInterval: Int) {
        
        myHarmonicFrequency = justRatios[adjustedInterval]! * myFundamentalFrequency
        
    }
    
    //---------------------------------------------------------------
    //got from http://www.medieval.org/emfaq/harmony/pyth4.html
    func determinePythagoreanHarmonicFrequency(adjustedInterval: Int) {
        
        myHarmonicFrequency = pythagreanRatios[adjustedInterval]! * myFundamentalFrequency

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
        myInstrumentBase.frequency.value = Float(myFundamentalFrequency)
        
        myInstrumentHarmony.frequency.value = Float(myHarmonicFrequency)
        
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
