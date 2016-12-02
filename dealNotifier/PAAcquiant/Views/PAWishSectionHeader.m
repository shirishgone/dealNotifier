//
//  PAWishSectionHeader.m
//  PAAcquiant
//
//  Created by Shirish on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAWishSectionHeader.h"
#include <QuartzCore/CoreAnimation.h>
#import "Wish.h"
#import "PADBManager.h"

#define kIconFrame_NormalMode   CGRectMake(10, 5, 60, 61)
#define kIconFrame_EditMode     CGRectMake(40, 5, 60, 61)
#define kTitleFrame_NormalMode  CGRectMake(80, 15, 220, 20)
#define kTitleFrame_EditMode    CGRectMake(110, 15, 220, 20)
#define kPriceLabel_NormalMode  CGRectMake(80, 40, 40, 15)
#define kPriceLabel_EditMode    CGRectMake(110, 40, 40, 15)
#define kPriceValue_NormalMode  CGRectMake(120, 40, 150, 15)
#define kPriceValue_EditMode    CGRectMake(150, 40, 150, 15)
#define kBadgeImageViewFrame    CGRectMake(40, 0, 22, 14)
#define kBadgeValueFrame        CGRectMake(0, 0, 22, 14)
#define kAddedonValue_NormalMode   CGRectMake(150, 45, 20, 15)
#define kAddedonValue_EditMode  CGRectMake(180, 45, 20, 15)

#define kIconImageViewTag   100
#define kTitleLabelTag      101
#define kPriceLabelTag      102
#define kPriceValueLabelTag 103
#define kBadgeImageViewTag  104
#define kBadgeValueTag      105
#define kArrowImageTag      106
#define kCheckmarkButtonTag 107

@interface  PAWishSectionHeader()
- (void)checkButtonTapped:(id)sender;
@end

@implementation PAWishSectionHeader
@synthesize  wish, disclosureButton, checkmarkButton, delegate, section, isEditMode;

-(id)initWithFrame:(CGRect)frame wish:(Wish  *)tempWish section:(NSInteger)sectionNumber suggessions:(NSInteger)suggessions isEditMode:(BOOL)tempIsEditMode delegate:(id <PAWishSectionHeaderViewDelegate>)aDelegate{
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.section = sectionNumber;
        delegate = aDelegate;        
        self.userInteractionEnabled = YES;
        self.isEditMode = tempIsEditMode;
        self.wish = tempWish;
        
        UIImage *backgroundImage = [UIImage imageNamed:kWishSectionBackgroundImage];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [backgroundImageView setFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        tapGestureRecognizer.numberOfTapsRequired =1;
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        UIImage *icon = [UIImage imageNamed:[[PADBManager sharedInstance] glyphForCategoryName:wish.CategoryName]];
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [iconImageView setTag:kIconImageViewTag];
        if (self.isEditMode) {
            [iconImageView setFrame:kIconFrame_EditMode];
        }
        else{
            [iconImageView setFrame:kIconFrame_NormalMode];
        }
        iconImageView.backgroundColor = [UIColor clearColor];
        [iconImageView setImage:icon];
        [self addSubview:iconImageView];
        [iconImageView release];
        
        UIImage *badgeImage = [UIImage imageNamed:@"cell_badge.png"];
        UIImageView *badgeImageView = [[UIImageView alloc] init];
        [badgeImageView setFrame:CGRectMake(280, (70 - badgeImage.size.height)/2, badgeImage.size.width, badgeImage.size.height)];
        [badgeImageView setTag:kBadgeImageViewTag];
        [badgeImageView setImage:badgeImage];
        [self addSubview:badgeImageView];
        
        UILabel *badgeValueLabel = [[UILabel alloc] init];
        [badgeValueLabel setTag:kBadgeValueTag];
        [badgeValueLabel setFrame:CGRectMake(0, 0, badgeImage.size.width, badgeImage.size.height)];
        [badgeValueLabel setBackgroundColor:[UIColor clearColor]];
        [badgeValueLabel setTextAlignment:UITextAlignmentCenter];
        [badgeValueLabel setTextColor:[UIColor whiteColor]];
        [badgeValueLabel setFont:[UIFont fontWithName:kBoldFont size:10]];
        [badgeValueLabel setText:[NSString stringWithFormat:@"%d",suggessions]];
        [badgeImageView addSubview:badgeValueLabel];
        [badgeImageView release];
        [badgeValueLabel release];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [titleLabel setTag:kTitleLabelTag];
        if (self.isEditMode) {
            [titleLabel setFrame:kTitleFrame_EditMode];
        }
        else{
            [titleLabel setFrame:kTitleFrame_NormalMode];
        }
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setTextColor:[UIColor colorWithRed:(63/255.0) green:(63/255.0) blue:(63/255.0) alpha:1.0]];
        [titleLabel setFont:[UIFont fontWithName:kBoldFont size:14]];
        [titleLabel setText: wish.CategoryName];
        [self addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *priceLabel = [[UILabel alloc] init];
        [priceLabel setTag:kPriceLabelTag];
        if (self.isEditMode) {
            [priceLabel setFrame:kPriceLabel_EditMode];
        }
        else{
            [priceLabel setFrame:kPriceLabel_NormalMode];
        }
        [priceLabel setBackgroundColor:[UIColor clearColor]];
        [priceLabel setTextAlignment:UITextAlignmentLeft];
        [priceLabel setTextColor:[UIColor colorWithRed:(63/255.0) green:(63/255.0) blue:(63/255.0) alpha:1.0]];
        [priceLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [priceLabel setText:@"Price:"];
        [self addSubview:priceLabel];
        [priceLabel release];
        
        float startPrice = [wish.PriceRangeStart floatValue];
        float endPrice = [wish.PriceRangeEnd  floatValue];
        NSString *priceValueString = [NSString stringWithFormat:@"$%d  to  $%d",(int)startPrice, (int)endPrice];
        
        UILabel *priceValueLabel = [[UILabel alloc] init];
        [priceValueLabel setTag:kPriceValueLabelTag];
        if (self.isEditMode) {
            [priceValueLabel setFrame:kPriceValue_EditMode];
        }
        else{
            [priceValueLabel setFrame:kPriceValue_NormalMode];
        }
        [priceValueLabel setBackgroundColor:[UIColor clearColor]];
        [priceValueLabel setTextAlignment:UITextAlignmentLeft];
        [priceValueLabel setTextColor:[UIColor colorWithRed:(63/255.0) green:(63/255.0) blue:(63/255.0) alpha:1.0]];
        [priceValueLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [priceValueLabel setText:priceValueString];
        [self addSubview:priceValueLabel];
        [priceValueLabel release];

        
        // Add arrow at the bottom
        // Create and configure the disclosure button.
        UIImage *arrowImage = [UIImage imageNamed:kArrowImage];
        self.disclosureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [disclosureButton setTag:kArrowImageTag];
        [disclosureButton setFrame:CGRectMake(self.frame.size.width/2 - (arrowImage.size.width/2), 70 - arrowImage.size.height, arrowImage.size.width, arrowImage.size.height)];
        if (self.isEditMode) {
            disclosureButton.selected = NO;
        }
        [disclosureButton setImage:nil forState:UIControlStateNormal];
        [disclosureButton setImage:arrowImage forState:UIControlStateSelected];
        [disclosureButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:disclosureButton];
        
        UIImage *unSelectedImage = [UIImage imageNamed:@"checkbox_empty.png"];
        UIImage *selectedImage = [UIImage imageNamed:@"checkbox_selected.png"];
        float xPos = (kIconFrame_EditMode.origin.x - unSelectedImage.size.width)/2;
        float yPos = (70 - unSelectedImage.size.height)/2;
        
        self.checkmarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [checkmarkButton setFrame:CGRectMake(xPos, yPos, unSelectedImage.size.width, unSelectedImage.size.height)];
        [checkmarkButton setImage:unSelectedImage forState:UIControlStateNormal];
        [checkmarkButton setImage:selectedImage forState:UIControlStateSelected];
        [checkmarkButton addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:checkmarkButton];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)toggleOpen:(id)sender {
    
    if (self.isEditMode == NO) {
        if ([delegate respondsToSelector:@selector(doesRowsExistsForSection:)]) {
            BOOL exists = [delegate doesRowsExistsForSection:self.section];
            if (exists == YES) {
                [self toggleOpenWithUserAction:YES];
            }
        }
    }else{
        [self checkButtonTapped:checkmarkButton];
    }
}


-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // Toggle the disclosure button state.
    disclosureButton.selected = !disclosureButton.selected;
    
    // If this was a user action, send the delegate the appropriate message.
    if (userAction) {
        if (disclosureButton.selected) {
            if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [delegate sectionHeaderView:self sectionOpened:section];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [delegate sectionHeaderView:self sectionClosed:section];
            }
        }
    }
}


- (void)dealloc {
    
    self.wish = nil;
    self.checkmarkButton = nil;
    self.disclosureButton = nil;
    [super dealloc];
}

#pragma mark - custom methods

- (void)setIsEditMode:(BOOL)tempIsEditMode{

    isEditMode = tempIsEditMode;
    
    UIImageView *iconImageView = (UIImageView *)[self viewWithTag:kIconImageViewTag];
    if (self.isEditMode) {
        [iconImageView setFrame:kIconFrame_EditMode];
    }
    else{
        [iconImageView setFrame:kIconFrame_NormalMode];
    }

    UILabel *titleLabel = (UILabel *)[self viewWithTag:kTitleLabelTag];
    if (self.isEditMode) {
        [titleLabel setFrame:kTitleFrame_EditMode];
    }
    else{
        [titleLabel setFrame:kTitleFrame_NormalMode];
    }
    
    UILabel *priceLabel = (UILabel *)[self viewWithTag:kPriceLabelTag];
    if (self.isEditMode) {
        [priceLabel setFrame:kPriceLabel_EditMode];
    }
    else{
        [priceLabel setFrame:kPriceLabel_NormalMode];
    }
    
    UILabel *priceValueLabel = (UILabel *)[self viewWithTag:kPriceValueLabelTag];
    if (self.isEditMode) {
        [priceValueLabel setFrame:kPriceValue_EditMode];
    }
    else{
        [priceValueLabel setFrame:kPriceValue_NormalMode];
    }

    if (self.isEditMode) {
        disclosureButton.selected = NO;
        checkmarkButton.hidden = NO;
    }else{
        checkmarkButton.hidden = YES;
    }
}

- (void)checkButtonTapped:(id)sender{

    checkmarkButton.selected = !checkmarkButton.selected;
    
}
@end
