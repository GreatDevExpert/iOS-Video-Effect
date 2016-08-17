//
// RETrimControl.m
// RETrimControl
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


#import "RETrimControl.h"

#define RANGESLIDER_THUMB_WIDTH (IS_IPAD ? 10 : 4)

#define OUTER_HEIGHT (IS_IPAD ? 10 : 5)
#define MIDDLE_HEIGHT (IS_IPAD ? 18 : 9)

#define TOP_INDICATOR_WIDTH (IS_IPAD ? 25 : 11)
#define TOP_INDICATOR_HEIGHT (IS_IPAD ? 22 : 10)

@implementation RETrimControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.threshold = 2;//22;
        
        _outerView = [[UIImageView alloc] initWithFrame:CGRectMake(_threshold, (frame.size.height - OUTER_HEIGHT)/ 2, frame.size.width - 1 - _threshold * 2, OUTER_HEIGHT)];
        _outerView.image = [[self bundleImageNamed:@"4th-Page_0016_slide-total"] stretchableImageWithLeftCapWidth:5 topCapHeight:0];
        [self addSubview:_outerView];
        
        _sliderMiddleView = [[UIControl alloc] initWithFrame:CGRectMake(0, (frame.size.height - MIDDLE_HEIGHT)/2, frame.size.width, MIDDLE_HEIGHT)];
        _sliderMiddleView.backgroundColor = [UIColor colorWithPatternImage:[self bundleImageNamed:@"SliderMiddle"]];
        [self addSubview:_sliderMiddleView];
        
        UIPanGestureRecognizer *middlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleMiddlePan:)];
        [self addGestureRecognizer:middlePan];
        
        _maxValue = 100;
        _minValue = 0;
        
        _leftValue = 0;
        _rightValue = 100;
        
        _leftThumbView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, RANGESLIDER_THUMB_WIDTH, MIDDLE_HEIGHT)];
        _leftThumbView.image = [self bundleImageNamed:@"Slider"];
        _leftThumbView.contentMode = UIViewContentModeLeft;
        _leftThumbView.userInteractionEnabled = YES;
        _leftThumbView.clipsToBounds = YES;
        [self addSubview:_leftThumbView];
        
        _rightThumbView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - RANGESLIDER_THUMB_WIDTH, 0, RANGESLIDER_THUMB_WIDTH, MIDDLE_HEIGHT)];
        _rightThumbView.image = [self bundleImageNamed:@"Slider"];
        _rightThumbView.contentMode = UIViewContentModeRight;
        _rightThumbView.userInteractionEnabled = YES;
        _rightThumbView.clipsToBounds = YES;
        [self addSubview:_rightThumbView];
        
        _topThumView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, TOP_INDICATOR_WIDTH, TOP_INDICATOR_HEIGHT)];
        _topThumView.image = [self bundleImageNamed:@"4th-Page_0013_current-"];
        _topThumView.contentMode = UIViewContentModeScaleToFill;
        _topThumView.userInteractionEnabled = YES;
        _topThumView.clipsToBounds = YES;
        [self addSubview:_topThumView];
    }
    return self;
}

- (void)layoutSubviews
{
    CGFloat availableWidth = self.frame.size.width - RANGESLIDER_THUMB_WIDTH;
    CGFloat inset = RANGESLIDER_THUMB_WIDTH / 2;

    CGFloat range = _maxValue - _minValue;

    CGFloat left = floorf((_leftValue - _minValue) / range * availableWidth);
    CGFloat right = floorf((_rightValue - _minValue) / range * availableWidth);

    if (isnan(left)) left = 0;
    if (isnan(right)) right = 0;

    _leftThumbView.center = CGPointMake(inset + left, self.frame.size.height/2);
    _rightThumbView.center = CGPointMake(inset + right, self.frame.size.height/2);
    _topThumView.center = CGPointMake(_leftThumbView.center.x, _leftThumbView.center.y-TOP_INDICATOR_HEIGHT);

    _sliderMiddleView.frame = CGRectMake(_leftThumbView.frame.origin.x + RANGESLIDER_THUMB_WIDTH, (self.frame.size.height - MIDDLE_HEIGHT)/2, _rightThumbView.frame.origin.x - _leftThumbView.frame.origin.x - RANGESLIDER_THUMB_WIDTH, MIDDLE_HEIGHT);

    _outerView.frame = CGRectMake(_threshold, (self.frame.size.height - OUTER_HEIGHT)/ 2, self.frame.size.width - 1 - _threshold * 2, _outerView.image.size.height);
}

- (UIImage *)bundleImageNamed:(NSString *)imageName
{
    return [UIImage imageNamed:imageName];
}

#pragma mark -
#pragma mark UIGestureRecognizer delegates

- (void)handleMiddlePan:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan || gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gesture translationInView:self];
        CGFloat range = _maxValue - _minValue;
        CGFloat availableWidth = self.frame.size.width - RANGESLIDER_THUMB_WIDTH;

        if (_leftValue + translation.x / availableWidth * range < 0) {
            CGFloat diff = _rightValue - _leftValue;
            _leftValue = 0;
            _rightValue = diff;

            return [self setNeedsLayout];
        }

        if (_rightValue + translation.x / availableWidth * range > 100) {
            CGFloat diff = _rightValue - _leftValue;
            _leftValue = 100 - diff;
            _rightValue = 100;

            return [self setNeedsLayout];
        }

        _leftValue += translation.x / availableWidth * range;
        _rightValue += translation.x / availableWidth * range;

        [gesture setTranslation:CGPointZero inView:self];

        [self setNeedsLayout];

        [self notifyDelegate];
    }
}

#pragma mark -
#pragma mark Utilities
- (void)notifyDelegate
{
    if ([_delegate respondsToSelector:@selector(trimControl:didChangeLeftValue:rightValue:)])
        [_delegate trimControl:self didChangeLeftValue:self.leftValue rightValue:self.rightValue];
}

#pragma mark -
#pragma mark Properties

- (CGFloat)leftValue
{
    return _leftValue * _length / 100.0f;
}

- (CGFloat)rightValue
{
    return _rightValue * _length / 100.0f;
}

@end
