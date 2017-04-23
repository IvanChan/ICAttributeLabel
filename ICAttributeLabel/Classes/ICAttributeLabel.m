//
//  ICAttributeLabel.m
//
//
//  Created by _ivanC on 6/12/15.
//  Copyright © 2015 _ivanC. All rights reserved.
//

#import "ICAttributeLabel.h"

@interface ICAttributeLabel ()

@property (nonatomic, assign) int currentAnimatedLineIndex;
@property (nonatomic, assign) CGPoint currentStrikethoughAnimatedPoint;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, strong) NSArray *lineAttributes;

@end

@implementation ICAttributeLabel

#pragma mark - Setters
- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self autoDoCalculate];
}

- (void)setText:(NSString *)text
{
    BOOL shouldCalculate = ![text isEqualToString:self.text];
    [super setText:text];

    if (shouldCalculate)
    {
        [self autoDoCalculate];
    }
}

- (void)setFont:(UIFont *)font
{
    BOOL shouldCalculate = !([self.font.familyName isEqualToString:font.familyName] && [self.font.fontName isEqualToString:font.fontName] && fabs((double)(self.font.pointSize - font.pointSize)) < 0.001);
                             
    [super setFont:font];
    
    if (shouldCalculate)
    {
        [self autoDoCalculate];
    }
}

- (void)setFrame:(CGRect)frame
{
    BOOL shouldCalculate = !CGSizeEqualToSize(frame.size, self.frame.size);
    [super setFrame:frame];
    
    if (shouldCalculate)
    {
        [self autoDoCalculate];
    }
}

- (void)setStrikethrough:(BOOL)strikethrough animated:(BOOL)animated
{
    if (strikethrough == _strikethrough)
    {
        return;
    }
    
    if (animated)
    {
        _currentAnimatedLineIndex = 0;
        
        if ([self.lineAttributes count] > 0)
        {
            ICLabelAttribute *attribute = [self.lineAttributes firstObject];
            _currentStrikethoughAnimatedPoint = CGPointMake(CGRectGetMinX(attribute.boundingRect), CGRectGetMidY(attribute.boundingRect));
        }
    }
    else
    {
        _currentAnimatedLineIndex = _lineCount - 1;
        
        if ([self.lineAttributes count] > 0)
        {
            ICLabelAttribute *attribute = [self.lineAttributes lastObject];
            _currentStrikethoughAnimatedPoint = CGPointMake(CGRectGetMaxX(attribute.boundingRect),
                                                            CGRectGetMidY(attribute.boundingRect));
        }
    }
    
    _strikethrough = strikethrough;
    [self setNeedsDisplay];
    
    if (animated)
    {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateAnimations)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else
    {
        [self _resetDisplayLink];
    }
}

#pragma mark - Calculate
- (void)autoDoCalculate
{
    if (![self isAutoCalculateDisabled])
    {
        [self setNeedsCalculate];
    }
}

- (void)setNeedsCalculate
{
    [self _calcTextAttributes];
}

- (void)_calcTextAttributes
{
    CGFloat width = CGRectGetWidth(self.bounds);
    NSString *text = self.text;
    UIFont *font = self.font;
    
    if (width <= 0 || [text length] <= 0)
    {
        return;
    }
    
    // Calc lineHeight
    CGRect temp = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:font}
                                     context:nil];
    _lineHeight = temp.size.height;
    
    CGFloat maxHeight = self.numberOfLines == 0 ? CGFLOAT_MAX :  _lineHeight * self.numberOfLines;

    NSParagraphStyle *paragraphStyle = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
    if (paragraphStyle && [paragraphStyle isKindOfClass:[NSParagraphStyle class]])
    {
        _lineSpaceHeight = paragraphStyle.lineSpacing;
    }
//    else
//    {
//        assert(0);
//    }
    
    // Calc area
    _textArea = [text boundingRectWithSize:CGSizeMake(width, maxHeight)
                                   options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:font}
                                   context:nil];
    
    // Guessing lineCount
    _lineCount = _textArea.size.height/_lineHeight;
    
    // Update with liceSpacing
    _textArea.size.height += _lineSpaceHeight * (_lineCount - 1);
    _textArea.origin.y = (CGRectGetHeight(self.bounds) - _textArea.size.height)/2.0;
    
    [self _calcDrawingAttributes];
    
    [self setNeedsDisplay];
}

- (void)_calcDrawingAttributes
{
    if (_lineCount <= 0 || CGSizeEqualToSize(_textArea.size, CGSizeZero))
    {
        return;
    }
    
    // calc block
    ICLabelAttribute* (^calcTextLen)(NSString *text, int startLen) = ^(NSString *text, int guessingLen){
        
        int overLen = -1;
        int lessLen = -1;
        int currentLen = guessingLen;
        
        CGRect boundingRect = CGRectZero;
        NSString *resultText = nil;
        do
        {
            NSString *tempText = nil;
            if ([text length] < currentLen )
            {
                tempText = text;
                currentLen = [text length];
                overLen = currentLen + 1;
            }
            else
            {
                tempText = [text substringToIndex:currentLen];;
            }
            
            CGRect tempRect = [tempText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:self.font}
                                                 context:nil];
            
            if (CGRectGetWidth(tempRect) > CGRectGetWidth(_textArea))
            {
                overLen = currentLen;
                currentLen--;
            }
            else
            {
                resultText = tempText;
                boundingRect = tempRect;
                lessLen = currentLen;
                currentLen++;
            }
            
            if (overLen > 0 && lessLen > 0)
            {
                break;
            }
            
        } while (1);
        
        ICLabelAttribute *attribute = [[ICLabelAttribute alloc] init];
        attribute.textCount = lessLen;
        attribute.boundingRect = boundingRect;
        attribute.text = resultText;
        
        return attribute;
    };
    
    int guessingTextLenForEachLine = [self.text length]/_lineCount;
    NSString *calcText = self.text;
    
    NSMutableArray *drawingDeatil = [NSMutableArray arrayWithCapacity:_lineCount];
    
    for (int i = 0; i < _lineCount; i++)
    {
        ICLabelAttribute *attribute = calcTextLen(calcText, guessingTextLenForEachLine);
        
        // fix rect origin
        {
            CGRect fixRect = attribute.boundingRect;
            
            if (self.textAlignment == NSTextAlignmentCenter)
            {
                fixRect.origin.x = (CGRectGetWidth(_textArea) - CGRectGetWidth(attribute.boundingRect))/2.0;
            }
            else if (self.textAlignment == NSTextAlignmentRight)
            {
                fixRect.origin.x = CGRectGetWidth(_textArea) - CGRectGetWidth(attribute.boundingRect);
            }
            
            fixRect.origin.y = (_lineHeight + _lineSpaceHeight)*i + CGRectGetMinY(_textArea);
            attribute.boundingRect = fixRect;
        }
        
        [drawingDeatil addObject:attribute];
        
        guessingTextLenForEachLine = attribute.textCount;
        if (guessingTextLenForEachLine >= [calcText length])
        {
            // some time calc may think there is n line, actually there is n+1
            guessingTextLenForEachLine = [calcText length] - 1;
        }
        
        if (i != _lineCount - 1)
        {
            calcText = [calcText substringFromIndex:guessingTextLenForEachLine];
        }
    }

    self.lineAttributes = drawingDeatil;
    
    assert(_lineCount == [_lineAttributes count]);
}

#pragma mark - Draw
- (void)_resetDisplayLink
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)updateAnimations
{
    if (_currentAnimatedLineIndex >= [self.lineAttributes count])
    {
        [self _resetDisplayLink];
        return;
    }
    
    ICLabelAttribute *attribute = self.lineAttributes[_currentAnimatedLineIndex];

    if (_currentStrikethoughAnimatedPoint.x >= CGRectGetMaxX(attribute.boundingRect))
    {
        _currentAnimatedLineIndex ++;
        if (_currentAnimatedLineIndex >= _lineCount)
        {
            [self _resetDisplayLink];
            return;
        }
        attribute = self.lineAttributes[_currentAnimatedLineIndex];
        _currentStrikethoughAnimatedPoint = CGPointMake(CGRectGetMinX(attribute.boundingRect), CGRectGetMidY(attribute.boundingRect));
    }
    
    CGFloat currentLineWidth = CGRectGetWidth(attribute.boundingRect);
    
    if (_strikethroughSpeed <= 0)
    {
        _strikethroughSpeed = 0.05;
    }
    
    CGFloat movingX = _currentStrikethoughAnimatedPoint.x + currentLineWidth * _strikethroughSpeed;
    if (movingX > CGRectGetMaxX(attribute.boundingRect))
    {
        movingX = CGRectGetMaxX(attribute.boundingRect);
    }
    
    _currentStrikethoughAnimatedPoint = CGPointMake(movingX, CGRectGetMidY(attribute.boundingRect));

    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    
    // draw strikethrough
    if ([self isStrikethrough] && [self.lineAttributes count] > 0)
    {
        void (^drawLine)(CGContextRef context, CGPoint fromPos, CGPoint toPos) = ^(CGContextRef context, CGPoint fromPos, CGPoint toPos){
            
            CGContextMoveToPoint(context, fromPos.x, fromPos.y);
            CGContextAddLineToPoint(context, toPos.x, toPos.y);
        };
        
        if (self.strikethroughColor == nil)
        {
            self.strikethroughColor = [UIColor redColor];
        }
        
        if (_strikethroughLineWidth <= 0)
        {
            _strikethroughLineWidth = 1;
        }
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.strikethroughColor set];
        CGContextSetLineWidth(context, _strikethroughLineWidth);
        
        // draw the previous lines
        for (int i = 0; i < _currentAnimatedLineIndex; i++)
        {
            ICLabelAttribute *attribute = self.lineAttributes[i];
            CGPoint lineStartPos = CGPointMake(CGRectGetMinX(attribute.boundingRect), CGRectGetMidY(attribute.boundingRect));
            CGPoint lineEndPos = CGPointMake(CGRectGetMaxX(attribute.boundingRect), lineStartPos.y);
            
            lineStartPos.x -= _strikethroughInsets.left;
            lineStartPos.y += (_strikethroughInsets.top - _strikethroughInsets.bottom);

            lineEndPos.x += _strikethroughInsets.right;
            lineEndPos.y += (_strikethroughInsets.top - _strikethroughInsets.bottom);
            
            drawLine(context, lineStartPos, lineEndPos);
        }
        
        // draw the current line
        ICLabelAttribute *attribute = self.lineAttributes[_currentAnimatedLineIndex];
        CGPoint lineStartPos = CGPointMake(CGRectGetMinX(attribute.boundingRect), CGRectGetMidY(attribute.boundingRect));
        CGPoint lineEndPos = _currentStrikethoughAnimatedPoint;
        
        lineStartPos.x -= _strikethroughInsets.left;
        lineStartPos.y += (_strikethroughInsets.top - _strikethroughInsets.bottom);
        
        lineEndPos.x += _strikethroughInsets.right;
        lineEndPos.y += (_strikethroughInsets.top - _strikethroughInsets.bottom);
        
        drawLine(context, lineStartPos, lineEndPos);
        
        CGContextStrokePath(context);
    }
}

@end

@implementation ICLabelAttribute

- (NSString *)description
{
    return [NSString stringWithFormat:@"<ICLabelAttribute: %p>, text = %@, textCount = %@, boundingRect = %@", self, self.text, @(self.textCount), [NSValue valueWithCGRect:self.boundingRect]];
}

@end
