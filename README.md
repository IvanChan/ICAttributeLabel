# ICAttributeLabel

[![CI Status](http://img.shields.io/travis/_ivanC/ICAttributeLabel.svg?style=flat)](https://travis-ci.org/_ivanC/ICAttributeLabel)
[![Version](https://img.shields.io/cocoapods/v/ICAttributeLabel.svg?style=flat)](http://cocoapods.org/pods/ICAttributeLabel)
[![License](https://img.shields.io/cocoapods/l/ICAttributeLabel.svg?style=flat)](http://cocoapods.org/pods/ICAttributeLabel)
[![Platform](https://img.shields.io/cocoapods/p/ICAttributeLabel.svg?style=flat)](http://cocoapods.org/pods/ICAttributeLabel)

  If you are heading for UILabel drawing information, you are in the right place.
  We calculate each line information of drawing for you, including text area each line.
  Also provide Strikethrough for animation.
  
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 8.0+

## Installation

ICAttributeLabel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ICAttributeLabel"
```

## Try it yourself
  ```
    ICAttributeLabel *label = [[ICAttributeLabel alloc] initWithFrame:CGRectMake(50, 100, 200, 100)];
    label.numberOfLines = 0;
    label.text = @"abcdefghijklmnopqrstuvwxyz1234567890";
    [self.view addSubview:label];
    NSLog(@"%@", label.lineAttributes);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [label setStrikethrough:YES animated:YES];
    });
  ```
  
  ```
  2016-03-26 01:54:35.343 ICUIKitDemo[1730:107711] (
    "<ICLabelAttribute: 0x7be9d220>, text = abcdefghijklmnopqrstuvw, textCount = 23, boundingRect = NSRect: {{0, 29.712891}, {197.70801, 20.287109}}",
    "<ICLabelAttribute: 0x7be9d300>, text = xyz1234567890, textCount = 13, boundingRect = NSRect: {{0, 50}, {125.23389, 20.287109}}"
  )
  ```
  
## Author

_ivanC

## License

ICAttributeLabel is available under the MIT license. See the LICENSE file for more info.
