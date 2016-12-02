//    Copyright 2011 Felipe Cypriano
// 
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
// 
//        http://www.apache.org/licenses/LICENSE-2.0
// 
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

#import "FCRangeSlider.h"
#include <QuartzCore/CoreAnimation.h>


#define FIXED_HEIGHT 30.0f

@interface FCRangeSlider (Private)
- (void)clipThumbToBounds;
- (void)updateInRangeTrackView;
- (void)swtichThumbsPositionIfNecessary;
- (void)updateRangeValue;
- (void)setThumbsPositionToNonFractionValues;
- (NSNumber *)roundValueFloat:(CGFloat)value;
- (void)updateThumbsPositionAnimated:(BOOL)animated;
- (void)safelySetMinMaxValues;
@end

@implementation FCRangeSlider 

@synthesize minimumValue;
@synthesize maximumValue;
@synthesize range;
@synthesize rangeValue;
@synthesize acceptOnlyNonFractionValues;

- (void)initialize {
    minimumValue = 0.0f;
    maximumValue = 10.0f;
    acceptOnlyNonFractionValues = NO;
    self.clipsToBounds = YES;
    
    UIImage *thumbImage = [UIImage imageNamed:@"slider_knob.png"];
    CGFloat thumbCenter = thumbImage.size.width / 2;
    trackSliderWidth = self.frame.size.width - thumbImage.size.width;

    UIImage *outRangeTrackImage = [UIImage imageNamed:@"slider_base.png"];
    outRangeTrackView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbCenter, 10, trackSliderWidth, 10)];
    outRangeTrackView.contentMode = UIViewContentModeScaleToFill;
    outRangeTrackView.backgroundColor = [UIColor clearColor];
    [outRangeTrackView setImage:outRangeTrackImage];
    [self addSubview:outRangeTrackView];
    
    UIImage *inRangeTrackImage = [UIImage imageNamed:@"slider_fill_middle.png"];
    inRangeTrackView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbCenter, 10, trackSliderWidth, 10)];
    inRangeTrackView.contentMode = UIViewContentModeScaleToFill;
    inRangeTrackView.backgroundColor = [UIColor clearColor];
    [inRangeTrackView setImage:inRangeTrackImage];
    [self addSubview:inRangeTrackView];
    
    minimumThumbView = [[UIImageView alloc] initWithImage:thumbImage];
    [minimumThumbView setFrame:CGRectMake(minimumThumbView.frame.origin.x, minimumThumbView.frame.origin.y, thumbImage.size.width, thumbImage.size.height)];
    //minimumThumbView.frame = CGRectSetHeight(minimumThumbView.frame, self.frame.size.height);
    minimumThumbView.contentMode = UIViewContentModeCenter;
    [self addSubview:minimumThumbView];
    
    maximumThumbView = [[UIImageView alloc] initWithImage:thumbImage];
    [maximumThumbView setFrame:CGRectMake(self.frame.size.width - thumbImage.size.width, 0, thumbImage.size.width, thumbImage.size.height)];
    maximumThumbView.contentMode = UIViewContentModeCenter;
    [self addSubview:maximumThumbView];
    
    roundFormatter = [[NSNumberFormatter alloc] init];
    [roundFormatter setMaximumFractionDigits:0];
    [roundFormatter setRoundingMode:NSNumberFormatterRoundHalfEven];
    
    self.rangeValue = FCRangeSliderValueMake(minimumValue, maximumValue);    
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, FIXED_HEIGHT)];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y ,self.frame.size.width, FIXED_HEIGHT)];
        //self.frame = CGRectSetHeight(self.frame, FIXED_HEIGHT);
        [self initialize];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    [minimumThumbView release];
    [inRangeTrackView release];
    [outRangeTrackView release];
    [super dealloc];
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:CGRectMake(newFrame.origin.x, newFrame.origin.y, newFrame.size.width, FIXED_HEIGHT)];
}

- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state {
    switch (state) {
        case UIControlStateNormal:
            minimumThumbView.image = image;
            maximumThumbView.image = image;
            break;
        case UIControlStateHighlighted:
            minimumThumbView.highlightedImage = image;
            maximumThumbView.highlightedImage = image;
        default:
            break;
    }
}

- (void)setOutRangeTrackImage:(UIImage *)image {
    outRangeTrackView.backgroundColor = [UIColor clearColor];
    outRangeTrackView.layer.cornerRadius = 0;
    outRangeTrackView.image = image;
}

- (void)setInRangeTrackImage:(UIImage *)image {
    inRangeTrackView.backgroundColor = [UIColor clearColor];
    inRangeTrackView.layer.cornerRadius = 0;
    inRangeTrackView.image = image;    
}

#pragma mark -
#pragma mark Value Setters

- (void)setMinimumValue:(CGFloat)newMinimumValue {
    CGFloat newMin = newMinimumValue;
    if (acceptOnlyNonFractionValues) {
        newMin = [[self roundValueFloat:newMinimumValue] floatValue];
    }
    
    minimumValue = newMin;
    [self safelySetMinMaxValues];

    if (rangeValue.start < minimumValue) {
        self.rangeValue = FCRangeSliderValueMake(minimumValue, rangeValue.end);
    } else {
        [self updateThumbsPositionAnimated:YES];
    }
}

- (void)setMaximumValue:(CGFloat)newMaximumValue {
    CGFloat newMax = newMaximumValue;
    if (acceptOnlyNonFractionValues) {
        newMax = [[self roundValueFloat:newMaximumValue] floatValue];
    }
    
    maximumValue = newMax;    
    [self safelySetMinMaxValues];

    if (rangeValue.end > maximumValue) {
        self.rangeValue = FCRangeSliderValueMake(rangeValue.start, maximumValue);
    } else {
        [self updateThumbsPositionAnimated:YES];
    }
}

- (void)setRangeValue:(FCRangeSliderValue)newRangeValue {
    [self setRangeValue:newRangeValue animated:NO];
}

- (void)setRange:(NSRange)newRange {
    [self setRange:newRange animated:NO];
}

- (void)setRangeValue:(FCRangeSliderValue)newRangeValue animated:(BOOL)animated {
    CGFloat safeStart = MAX(newRangeValue.start, minimumValue);
    CGFloat safeEnd = MIN(newRangeValue.end, maximumValue);
    
    if (acceptOnlyNonFractionValues) {
        safeStart = [[self roundValueFloat:safeStart] floatValue];
        safeEnd = [[self roundValueFloat:safeEnd] floatValue];
    }
    
    rangeValue = FCRangeSliderValueMake(safeStart, safeEnd);
    
    NSInteger minInt = [[self roundValueFloat:safeStart] integerValue];
    NSInteger maxInt = [[self roundValueFloat:safeEnd] integerValue];
    range = NSMakeRange(minInt, maxInt - minInt + 1);    
    
    if (!isTracking) {
        [self updateThumbsPositionAnimated:animated];
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setRange:(NSRange)newRange animated:(BOOL)animated {
    CGFloat start = [[NSNumber numberWithInteger:newRange.location] floatValue];
    CGFloat end = [[NSNumber numberWithInteger:NSMaxRange(newRange) - 1] floatValue];
    
    [self setRangeValue:FCRangeSliderValueMake(start, end) animated:animated];
}

- (void)setAcceptOnlyNonFractionValues:(BOOL)newAcceptOnlyNonFractionValues {
    if (newAcceptOnlyNonFractionValues != acceptOnlyNonFractionValues && newAcceptOnlyNonFractionValues) {
        [self setRange:range animated:YES];
        self.minimumValue = [[self roundValueFloat:minimumValue] floatValue];
        self.maximumValue = [[self roundValueFloat:maximumValue] floatValue];
    }
    acceptOnlyNonFractionValues = newAcceptOnlyNonFractionValues;
}

#pragma mark -
#pragma mark Drag handling

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self safelySetMinMaxValues];
    isTracking = YES;
    
    CGPoint touchPoint = [touch locationInView:self];
    if (CGRectContainsPoint(minimumThumbView.frame, touchPoint)) {
        thumbBeingDragged = minimumThumbView;
    } else if (CGRectContainsPoint(maximumThumbView.frame, touchPoint)) {
        thumbBeingDragged = maximumThumbView;
    } else {
        [self cancelTrackingWithEvent:event];
        thumbBeingDragged = nil;
        return NO;
    }
    
    thumbBeingDragged.highlighted = YES;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (thumbBeingDragged) {
        CGPoint touchPoint = [touch locationInView:self];
        thumbBeingDragged.center = CGPointMake(touchPoint.x, thumbBeingDragged.center.y);
        [self clipThumbToBounds];
        [self swtichThumbsPositionIfNecessary];
        [self updateInRangeTrackView];
        
        [self updateRangeValue];
        return YES;
    } else {
        return NO;
    }
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    isTracking = NO;

    if (acceptOnlyNonFractionValues) {
        [self setThumbsPositionToNonFractionValues];
        [self updateRangeValue];
    }
    
    thumbBeingDragged.highlighted = NO;
    thumbBeingDragged = nil;
//    DLog(@"selected range %f %f | %d %d", rangeValue.start, rangeValue.end, range.location, range.length);
}

#pragma mark -
#pragma mark Private methods

- (void)clipThumbToBounds {
    if (thumbBeingDragged.frame.origin.x < 0) {
        [thumbBeingDragged setFrame:CGRectMake(0, thumbBeingDragged.frame.origin.y, thumbBeingDragged.frame.size.width,thumbBeingDragged.frame.size.height)];
        //thumbBeingDragged.frame = CGRectSetPositionX(thumbBeingDragged.frame, 0);
    } else if (thumbBeingDragged.frame.origin.x + thumbBeingDragged.bounds.size.width > self.bounds.size.width) {
        [thumbBeingDragged setFrame:CGRectMake(self.bounds.size.width - thumbBeingDragged.bounds.size.width, thumbBeingDragged.frame.origin.y,thumbBeingDragged.bounds.size.width, thumbBeingDragged.frame.size.height)];
        //thumbBeingDragged.frame = CGRectSetPositionX(thumbBeingDragged.frame, self.bounds.size.width - thumbBeingDragged.bounds.size.width);
    }    
}

- (void)swtichThumbsPositionIfNecessary {
    if (thumbBeingDragged == minimumThumbView && (thumbBeingDragged.frame.origin.x >= maximumThumbView.frame.origin.x + maximumThumbView.frame.size.height)) {
        minimumThumbView = maximumThumbView;
        maximumThumbView = thumbBeingDragged;
    } else if (thumbBeingDragged == maximumThumbView && thumbBeingDragged.frame.origin.x + thumbBeingDragged.frame.size.height <= minimumThumbView.frame.origin.x) {
        maximumThumbView = minimumThumbView;
        minimumThumbView = thumbBeingDragged;
    }
}

- (void)updateInRangeTrackView {
    CGFloat newX = minimumThumbView.center.x;
    CGFloat newWidth = maximumThumbView.frame.origin.x + (maximumThumbView.bounds.size.width / 2) - newX;
    inRangeTrackView.frame = CGRectMake(newX, inRangeTrackView.frame.origin.y, newWidth, inRangeTrackView.bounds.size.height);
}

- (void)updateRangeValue {
    CGFloat valueSpan = maximumValue - minimumValue;
    CGPoint minPointInTrack = [self convertPoint:minimumThumbView.center toView:outRangeTrackView];
    CGFloat min = minimumValue + minPointInTrack.x / trackSliderWidth * valueSpan;
    CGPoint maxPointInTrack = [self convertPoint:maximumThumbView.center toView:outRangeTrackView];
    CGFloat max = minimumValue + maxPointInTrack.x /trackSliderWidth * valueSpan;
    
    self.rangeValue = FCRangeSliderValueMake(min, max);
}

- (void)setThumbsPositionToNonFractionValues {
    [self setRange:range animated:YES];
}

- (void)updateThumbsPositionAnimated:(BOOL)animated {
    CGFloat valueSpan = maximumValue - minimumValue;
    CGFloat currentMinValue = rangeValue.start - minimumValue;
    CGFloat currentMaxValue = rangeValue.end - minimumValue;
    
    CGFloat minPointXInTrack = trackSliderWidth / valueSpan * currentMinValue;
    CGPoint minCenter = [self convertPoint:CGPointMake(minPointXInTrack, 0) fromView:outRangeTrackView];
    
    CGFloat maxPoinXtInTrack = trackSliderWidth / valueSpan * currentMaxValue;
    CGPoint maxCenter = [self convertPoint:CGPointMake(maxPoinXtInTrack, 0) fromView:outRangeTrackView];

    void (^move)(void) = ^{
        minimumThumbView.center = CGPointMake(minCenter.x, minimumThumbView.center.y);
        maximumThumbView.center = CGPointMake(maxCenter.x, maximumThumbView.center.y);
        [self updateInRangeTrackView];
    };
    
    void (^adjustRect)(BOOL) = ^(BOOL finished) {
        minimumThumbView.frame = CGRectIntegral(minimumThumbView.frame);
        maximumThumbView.frame = CGRectIntegral(maximumThumbView.frame);
    };
    
    if (animated) {
        [UIView animateWithDuration:.3 animations:move completion:adjustRect];
    } else {
        move();
        adjustRect(YES);
    }
}

- (NSNumber *)roundValueFloat:(CGFloat)value {
    return [roundFormatter numberFromString:[roundFormatter stringFromNumber:[NSNumber numberWithFloat:value]]];
}

- (void) safelySetMinMaxValues {
    if (minimumValue > maximumValue) {
        CGFloat switchValues = minimumValue;
        minimumValue = maximumValue;
        maximumValue = switchValues;
    } else if (maximumValue < minimumValue) {
        CGFloat switchValues = maximumValue;
        maximumValue = minimumValue;
        minimumValue = switchValues;
    }
    
}

@end
