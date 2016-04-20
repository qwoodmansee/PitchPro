//
//  SegmentedControl.swift
//  Pitch Pro
//
//  Created by Quinton Woodmansee on 4/19/16.
//  Copyright © 2016 Quinton Woodmansee. All rights reserved.
//

import UIKit

@IBDesignable class QSegmentedControl: UIControl {

    private var labels = [UILabel]()
    var thumbView = UIView()
    
    var items: [String] = ["♭", "♮", "#"] {
        didSet {
            setUpLabels()
        }
    }
    
    var selectedIndex : Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        setupView()
    }
    
    func setupView() {
        
        layer.cornerRadius = frame.height / 2
        layer.borderColor = UIColor(white:1.0, alpha: 0.5).CGColor
        layer.borderWidth = 2
        
        backgroundColor = UIColor.clearColor()
        
        setUpLabels()
        
        insertSubview(thumbView, atIndex: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var selectedFrame = self.bounds
        let newWidth = CGRectGetWidth(selectedFrame) / CGFloat(items.count)
        
        selectedFrame.size.width = newWidth
        thumbView.frame = selectedFrame
        thumbView.backgroundColor = UIColor.whiteColor()
        thumbView.layer.cornerRadius = thumbView.frame.height / 2
        
        let labelHeight = self.bounds.height
        let labelWidth = self.bounds.width / CGFloat(labels.count)
        
        for index in 0...labels.count - 1 {
            var label = labels[index]
            let xPosition = CGFloat(index) * labelWidth
            label.frame = CGRectMake(xPosition, 0, labelWidth, labelHeight)
        }
        
    }
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        var calculatedIndex : Int?
        for (index, item) in labels.enumerate() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActionsForControlEvents(.ValueChanged)
        }
        
        return false
    }
    
    func displayNewSelectedIndex() {
        var label = labels[selectedIndex]
        self.thumbView.frame = label.frame
    }
    
    func setUpLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepCapacity: true)
        
        for index in 1...items.count {
            let label = UILabel(frame: CGRectZero)
            label.text = items[index-1]
            label.textAlignment = .Center
            label.textColor = UIColor(white: 0.5, alpha: 1.0)
            self.addSubview(label)
            labels.append(label)
        }
    }
    
    
}
