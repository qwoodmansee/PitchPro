//
//  Instrument.swift
//  Frequency Generation Testing
//
//  Created by Quinton Woodmansee on 1/12/16.
//  Copyright © 2016 Quinton Woodmansee. All rights reserved.
//


class BasicSynth: AKInstrument {
    
    var frequency = AKInstrumentProperty(value: 200, minimum: 20, maximum: 20000)
    var amplitude = AKInstrumentProperty(value : 0.5, minimum: 0, maximum: 1)

    
    override init() {
        super.init()
        
        addProperty(frequency)
        addProperty(amplitude)
        
        let basicOscillator = AKOscillator()
        basicOscillator.frequency = frequency
        basicOscillator.amplitude = amplitude
        
        setAudioOutput(basicOscillator)
    }
    
}