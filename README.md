# JLColorPicker
a simple color Picker

<img src="2016-09-03%2013_11_46.gif" width="300">


## Usage
Just add `colorPickerView.swift` to your project and subclass your UIImageView to "colorPickerView"

```Swift
@IBOutlet var imageView: colorPickerView!

//Turn on the picker
imageView.isPicking = true
```

Two delegates
```Swift
protocol colorPickerDelegate {
    func colorDidChange(color: UIColor)

    func didEndPick(color: UIColor)
}

```

For more info, please check the demo
