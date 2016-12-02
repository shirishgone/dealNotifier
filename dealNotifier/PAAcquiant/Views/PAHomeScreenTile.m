//
//  PAHomeScreenTile.m
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAHomeScreenTile.h"
#import "PADBManager.h"

#define kButtonTag      100

@implementation PAHomeScreenTile
@synthesize delegate = delegate_;
@synthesize category = category_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UIButton *tileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tileButton setTag:kButtonTag];
        [tileButton setBackgroundColor:[UIColor clearColor]];
        [tileButton addTarget:self action:@selector(categorySelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tileButton];

    }
    return self;
}
- (void)dealloc{
    self.delegate = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setCategory:(PACategory)category{
    category_ = category;
    PADBManager *dataManager = [PADBManager sharedInstance];
    
    UIImage *backgroundSelected = [UIImage imageNamed:@"pressed_overlay.png"];
    UIImage *tileImage         = [UIImage imageNamed:[dataManager tileImageForCategory:category]];
    
    // Set the images for the tile image view
    UIButton *tileButton = (UIButton *)[self viewWithTag:kButtonTag];
    [tileButton setBackgroundColor:[UIColor clearColor]];
    [tileButton setBackgroundImage:backgroundSelected forState:UIControlStateSelected];
    [tileButton setImage:tileImage forState:UIControlStateNormal];
    [tileButton setImage:tileImage forState:UIControlStateSelected];
    [tileButton setFrame:CGRectMake(0, 0, tileImage.size.width, tileImage.size.height)];    
}

#pragma mark - action handlers

- (void)categorySelected:(id)sender{
    
    if (delegate_ && [delegate_ respondsToSelector:@selector(didSelectCategory:)]) {
        [delegate_ didSelectCategory:category_];
    }
}
@end
