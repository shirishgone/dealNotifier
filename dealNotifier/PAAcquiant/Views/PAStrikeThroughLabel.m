//
//  PAStrikeThroughLabel.m
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAStrikeThroughLabel.h"

@implementation PAStrikeThroughLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGSize stringSize = [self.text sizeWithFont:[UIFont systemFontOfSize:18.0]];
    // Drawing code
    CGContextRef c = UIGraphicsGetCurrentContext(); 
    CGFloat red[4] = {(167.0/255.0), (67.0/255.0), (67.0/255.0), 1.0f};
    CGContextSetStrokeColor(c, red);
    CGContextSetLineWidth(c, 2.0);
    CGContextBeginPath(c);
    CGFloat halfWayUp = (self.bounds.size.height - self.bounds.origin.y) / 2.0;
    CGContextMoveToPoint(c, self.bounds.origin.x, halfWayUp );
    CGContextAddLineToPoint(c, self.bounds.origin.x + stringSize.width, halfWayUp);
    CGContextStrokePath(c);
    
    [super drawRect:rect];
}



@end
