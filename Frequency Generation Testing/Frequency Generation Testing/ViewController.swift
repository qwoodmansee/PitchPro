//
//  ViewController.swift
//  Frequency Generation Testing
//
//  Created by Quinton Woodmansee on 1/12/16.
//  Copyright © 2016 Quinton Woodmansee. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    
    var frequencies: [Float] = [16.35,17.32,18.35,19.45,20.60,21.83,23.12,24.50,25.96,27.50,29.14,30.87]

    var flat : Bool = false
    var sharp : Bool = false
    
    let myInstrument = BasicSynth()
    @IBOutlet weak var currentOctave: UIStepper!
    
    @IBOutlet weak var amplitudeSlider: AKPropertySlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        AKOrchestra.addInstrument(myInstrument)
        amplitudeSlider.property = myInstrument.amplitude
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func PlayC(sender: AnyObject) {
        let temp : Int = sender.tag - 1
        print(temp)
        myInstrument.frequency.value = frequencies[temp] * Float(pow(Double(2),Double(currentOctave.value)))
        myInstrument.play()
        
    }

    @IBAction func StopPlayingC(sender: AnyObject) {
        myInstrument.stop()
    }

}

