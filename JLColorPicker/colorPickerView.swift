//
//  colorPickerView.swift
//  JLColorPicker
//
//  Created by 刘业臻 on 16/9/2.
//  Copyright © 2016年 luiyezheng. All rights reserved.
//

import UIKit

class colorPickerView: UIImageView, UIGestureRecognizerDelegate {
    var picker: UIView?

    //MARK: Properties
    var touchLocation: CGPoint = CGPoint.zero
    var beginningPoint: CGPoint = CGPoint.zero
    var beginningCenter: CGPoint?
    var pixelData: CFData?
    var colorInfo: UIColor?
    var isPicking: Bool = false {
        didSet {
            if isPicking {
                guard let picker = picker else {return}
                addSubview(picker)
                picker.center = self.center
                if pixelData != nil && self.image != nil {
                    picker.backgroundColor = getPixelColor(picker.center, pixelData: pixelData!, image: self.image!)
                }

            } else {
                picker?.removeFromSuperview()
                pixelData = nil
            }
        }
    }
    var delegate: colorPickerDelegate?

    //MARK: pan gesture
    lazy var panGesture: UIPanGestureRecognizer = {
       let gesture = UIPanGestureRecognizer(target: self, action: #selector(colorPickerView.panGestureHandler(_:)))
        gesture.delegate = self
        return gesture

    }()


    //MARK: init
    init() {
        super.init(frame: CGRect.zero)
        setup()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()

    }

    /**
     Setup the subViews and the data if the iamge is available
     */
    func setup() {
        let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
        picker = UIView(frame: rect)
        picker?.layer.cornerRadius = 15
        picker?.layer.borderWidth = 3.0
        picker?.layer.masksToBounds = false
        picker?.layer.borderColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        picker?.addGestureRecognizer(panGesture)

        if self.image != nil {
            pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.image!.CGImage))
        }

    }


    //MARK: Gesture handler
    func panGestureHandler(recognizer: UIPanGestureRecognizer) {

        touchLocation = recognizer.locationInView(self)
        guard let picker = picker else {return}

        switch recognizer.state {

        case .Began:
            if beginningCenter == nil {
                beginningCenter = self.center
            }

            UIView.animateWithDuration(0.1) {
                picker.transform = CGAffineTransformMakeScale(2, 2)
            }

            picker.center = beginningCenter!
        case .Changed:
            picker.center = touchLocation
            beginningCenter = touchLocation

            let xPoint = touchLocation.x
            let yPoint = touchLocation.y
            beginningCenter = touchLocation

            if image != nil && pixelData != nil {
                let color = getPixelColor(CGPoint(x: xPoint, y: yPoint), pixelData: pixelData!, image: self.image!)
                colorInfo = color
                picker.backgroundColor = color

                if let delegate = delegate {
                    delegate.colorDidChange(color)
                }

            }

        case .Ended:
            let xPoint = touchLocation.x
            let yPoint = touchLocation.y
            beginningCenter = touchLocation

            if image != nil && pixelData != nil {
                let color = getPixelColor(CGPoint(x: xPoint, y: yPoint), pixelData: pixelData!, image: self.image!)
                colorInfo = color
                picker.backgroundColor = color

                if let delegate = delegate {
                    delegate.didEndPick(color)
                }

            }
            UIView.animateWithDuration(0.1) {
                picker.transform = CGAffineTransformMakeScale(1.0, 1.0)
            }


        default:break
        }
    }

    /**
     Get the color of a given pixel inside an image

     - parameter pos:       point
     - parameter pixelData: the pixel information of image
     - parameter image:     the image

     - returns: the color of the pixel
     */
    private func getPixelColor(pos: CGPoint, pixelData: CFData, image: UIImage) -> UIColor {
        let imageWidth = image.size.width
        let imageHeight = image.size.height

        let realWidth = imageScale().width * imageWidth
        let realHeight = imageScale().height * imageHeight

        let newCoordinateX = pos.x * (imageWidth / realWidth)
        let newCoordinateY = (pos.y - ((frame.height - realHeight) / 2)) * (imageHeight / realHeight)
        let newPos = CGPointMake(newCoordinateX, newCoordinateY)

        //Fix: How to retain the data
        let data = CFDataGetBytePtr(pixelData)

        let pixelInfo: Int = ((Int(image.size.width) * Int(newPos.y)) + Int(newPos.x)) * 4

        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// Override the iamge to regenerate the pixelData when the image is set
    override var image: UIImage? {
        didSet {
            super.image = image
            if image != nil {
                pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image!.CGImage))
            }
        }
    }
}
protocol colorPickerDelegate {
    func colorDidChange(color: UIColor)

    func didEndPick(color: UIColor)
}
extension colorPickerDelegate {
    func colorDidChange(color: UIColor) {

    }

    func didEndPick(color: UIColor) {

    }
}

extension UIImageView {
    func imageScale() -> CGSize {
        guard let image = self.image else {return CGSize.zero}
        let sx = self.frame.size.width / image.size.width
        let sy = self.frame.size.height / image.size.height
        var s: Float = 1.0

        switch self.contentMode {
        case .ScaleAspectFit:
            s = fminf(Float(sx), Float(sy))
            return CGSizeMake(CGFloat(s), CGFloat(s))

        case .ScaleAspectFill:
            s = fmaxf(Float(sx), Float(sy))
            return CGSizeMake(CGFloat(s), CGFloat(s))
        case .ScaleToFill:
            return CGSizeMake(sx, sy)

        default:
            return CGSizeMake(CGFloat(s), CGFloat(s))
        }
    }


}
