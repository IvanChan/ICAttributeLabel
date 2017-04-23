//
//  ICAttributeLabel.h
//  
//
//  Created by _ivanC on 6/12/15.
//  Copyright © 2015 _ivanC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ICAttributeLabel : UILabel

@property (nonatomic, assign, readonly) NSInteger lineCount;
@property (nonatomic, assign, readonly) CGFloat  lineHeight;
@property (nonatomic, assign, readonly) CGFloat  lineSpaceHeight;
@property (nonatomic, assign, readonly) CGRect  textArea;

@property (nonatomic, strong, readonly) NSArray *lineAttributes;    // ICLabelAttribute for each line

@property (nonatomic, assign, getter=isStrikethrough, readonly) BOOL strikethrough;
@property (nonatomic, strong) UIColor *strikethroughColor;          // Default is RedColor
@property (nonatomic, assign) CGFloat strikethroughLineWidth;       // Default is 1
@property (nonatomic, assign) CGFloat strikethroughSpeed;           // Default is 0.05
@property (nonatomic, assign) UIEdgeInsets strikethroughInsets;     // Default is UIEdgeInsetsZero

- (void)setStrikethrough:(BOOL)strikethrough animated:(BOOL)animated;

@property (nonatomic, assign, getter=isAutoCalculateDisabled) BOOL autoCalculateDisabled;       // Default is NO, but set to YES if causing some performance problem in table-scrolling,  and call setNeedsCalculate when there is a perfect time

- (void)setNeedsCalculate;    // force to calculate one time

@end

@interface ICLabelAttribute : NSObject

@property (nonatomic, assign) CGRect boundingRect;
@property (nonatomic, assign) int textCount;

@property (nonatomic, strong) NSString *text;

@end