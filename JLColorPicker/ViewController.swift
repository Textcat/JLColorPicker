//
//  ViewController.swift
//  JLColorPicker
//
//  Created by 刘业臻 on 16/9/1.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

class ViewController: UIViewController, colorPickerDelegate {

    @IBOutlet var imageView: colorPickerView!
    @IBOutlet var colroLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.isPicking = true
        imageView.delegate = self

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func colorDidChange(color: UIColor) {
        let newColor = color.coreImageColor
        let r = Int(newColor.red * 256)
        let g = Int(newColor.blue * 256)
        let b = Int(newColor.blue * 256)
        //let alpha = newColor.alpha

        let hexCode = "red:" + String(r) + ", green:" + String(g) + ", blue:" + String(b)
        
        colroLabel.text = hexCode
    }
}

extension UIColor {
    var coreImageColor: CoreImage.CIColor {
        return CoreImage.CIColor(color: self)  // The resulting Core Image color, or nil
    }
}
