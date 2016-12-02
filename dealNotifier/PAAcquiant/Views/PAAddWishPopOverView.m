//
//  PAAddWishPopOverView.m
//  ProjectAcquaint
//
//  Created by Shirish on 8/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PAAddWishPopOverView.h"
#include <QuartzCore/CoreAnimation.h>
#import "PADBManager.h"
#import "FCRangeSlider.h"
#import "Reachability.h"

#define kPopOverTag 111
#define kMaxWishes  10

#define kStartValueLabelTag 100
#define kEndValueLabelTag   101
#define kSliderBackgroundViewTag    102
#define kTextLabelTag       103
#define kOkButtonTag        104
#define kCancelButtonTag    105

#define kTransparentBackground  @"transparent_Background.png"
#define kPopOverBackground      @"base.png"

#define kPictureFrameImage      @"popOver_imageCell.png"
#define kRangeSliderBackground  @"popOver_cellBackground.png"
#define kTitleColor    [UIColor colorWithRed:(45.0/255) green:(49.0/255) blue:(51.0/255) alpha:1.0]
@interface PAAddWishPopOverView()
- (void)showError;
- (int)minPriceForCategory:(PACategory)category;
- (int)maxPriceForCategory:(PACategory)category;
@end

@implementation PAAddWishPopOverView
@synthesize     delegate = delegate_;
- (void)dealloc{
    self.delegate = nil;
    [dealDetails_ release];
    [slider_ release];
    [textField_ release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame andDealDetails:(PADealDetail *)dealDetails andDelegate:(id)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        delegate_ = delegate;
        dealDetails_ = [dealDetails retain];
        startPrice_ = [self minPriceForCategory:dealDetails_.category];
        endPrice_ = [self maxPriceForCategory:dealDetails_.category];
        
        UIImage *backgroundImage  = [UIImage imageNamed:@"Overlay.png"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
        [backgroundImageView setImage:backgroundImage];
        [backgroundImageView setUserInteractionEnabled:NO];
        [self addSubview:backgroundImageView];
        [backgroundImageView release];
        
        UIImage *popOverBackgroundImage  = [UIImage imageNamed:@"popup_bg.png"];
        float xPos =  (self.frame.size.width - popOverBackgroundImage.size.width )/2.0;
        float yPos =  (self.frame.size.height - popOverBackgroundImage.size.height)/2.0+10.0;
        UIImageView *popOverBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, yPos, popOverBackgroundImage.size.width, popOverBackgroundImage.size.height)];
        [popOverBackgroundImageView setBackgroundColor:[UIColor clearColor]];
        popOverBackgroundImageView.tag = kPopOverTag;
        [popOverBackgroundImageView setImage:popOverBackgroundImage];
        popOverBackgroundImageView.userInteractionEnabled = YES;
        [self addSubview:popOverBackgroundImageView];
        
        PADBManager *dataManager = [PADBManager sharedInstance];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, popOverBackgroundImage.size.width, 25)];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [titleLabel setTextAlignment:UITextAlignmentCenter];
        [titleLabel setTextColor:[UIColor whiteColor]];
        [titleLabel setText:[dataManager categoryNameForCategory:dealDetails_.category]];
        [popOverBackgroundImageView addSubview:titleLabel];
        [titleLabel release];

        UIImage *wishImage = [UIImage imageNamed:[dataManager categoryImageInAddWishForCategory:dealDetails_.category]];
        int glyphXPos = (popOverBackgroundImageView.frame.size.width - wishImage.size.width)/2;
        int glyphYPos = 55;        
        UIImageView *wishImageView = [[UIImageView alloc] initWithFrame:CGRectMake(glyphXPos, glyphYPos, wishImage.size.width, wishImage.size.height)];
        [wishImageView setBackgroundColor:[UIColor clearColor]];
        [wishImageView setImage:wishImage];
        [popOverBackgroundImageView addSubview:wishImageView];
        [wishImageView release];
        
        UIImage *rangeSliderBckgrdImage = [UIImage imageNamed:@"popup_cell.png"];
        int rangeSliderBckgrdXPos = (popOverBackgroundImageView.frame.size.width - rangeSliderBckgrdImage.size.width)/2;
        UIImageView *rangeSliderBackgrdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(rangeSliderBckgrdXPos, 135, rangeSliderBckgrdImage.size.width, rangeSliderBckgrdImage.size.height)];
        [rangeSliderBackgrdImageView setTag:kSliderBackgroundViewTag];
        [rangeSliderBackgrdImageView setImage:rangeSliderBckgrdImage];
        [popOverBackgroundImageView addSubview:rangeSliderBackgrdImageView];
        
        UILabel *priceRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 90, 20)];
        [priceRangeLabel setBackgroundColor:[UIColor clearColor]];
        [priceRangeLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [priceRangeLabel setTextAlignment:UITextAlignmentLeft];
        [priceRangeLabel setTextColor:[UIColor whiteColor]];
        [priceRangeLabel setText:@"Price Range:"];
        [rangeSliderBackgrdImageView addSubview:priceRangeLabel];
        [priceRangeLabel release];
        [rangeSliderBackgrdImageView release];
        
        slider_ = [[FCRangeSlider alloc] initWithFrame:CGRectMake(5, 35, 275, 20)];
        [slider_ setBackgroundColor:[UIColor clearColor]];
        [slider_ setThumbImage:[UIImage imageNamed:@"slider_knob.png"] forState:UIControlStateNormal];
        [slider_ setThumbImage:[UIImage imageNamed:@"slider_knob.png"] forState:UIControlStateHighlighted];
        [slider_ addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [rangeSliderBackgrdImageView addSubview:slider_];
        [rangeSliderBackgrdImageView setUserInteractionEnabled:YES];
        
        
        UILabel *startValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 5, 40, 20)];
        [startValueLabel setTag:kStartValueLabelTag];
        [startValueLabel setBackgroundColor:[UIColor clearColor]];
        [startValueLabel setFont:[UIFont fontWithName:kBoldFont size:13]];
        [startValueLabel setTextAlignment:UITextAlignmentLeft];
        [startValueLabel setTextColor:[UIColor colorWithRed:(157.0/255.0) green:(157.0/255.0) blue:(157.0/255.0) alpha:1.0]];
        [startValueLabel setText:[NSString stringWithFormat:@"$%d",startPrice_]];
        [rangeSliderBackgrdImageView addSubview:startValueLabel];
        [startValueLabel release];
        
        UILabel *dividerLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, 5, 5, 20)];
        [dividerLabel setBackgroundColor:[UIColor clearColor]];
        [dividerLabel setFont:[UIFont fontWithName:kBoldFont size:13]];
        [dividerLabel setTextAlignment:UITextAlignmentLeft];
        [dividerLabel setTextColor:[UIColor colorWithRed:(157.0/255.0) green:(157.0/255.0) blue:(157.0/255.0) alpha:1.0]];
        [dividerLabel setText:@"-"];
        [rangeSliderBackgrdImageView addSubview:dividerLabel];
        [dividerLabel release];
        
        UILabel *endValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 5, 40, 20)];
        [endValueLabel setTag:kEndValueLabelTag];
        [endValueLabel setBackgroundColor:[UIColor clearColor]];
        [endValueLabel setFont:[UIFont fontWithName:kBoldFont size:13]];
        [endValueLabel setTextAlignment:UITextAlignmentLeft];
        [endValueLabel setTextColor:[UIColor colorWithRed:(157.0/255.0) green:(157.0/255.0) blue:(157.0/255.0) alpha:1.0]];
        [endValueLabel setText:[NSString stringWithFormat:@"$%d",endPrice_]];
        [rangeSliderBackgrdImageView addSubview:endValueLabel];
        [endValueLabel release];
        
        int keywordsBckgrdXPos = (popOverBackgroundImageView.frame.size.width - rangeSliderBckgrdImage.size.width)/2;
        UIImageView *keywordsBackgrdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(keywordsBckgrdXPos, 230, rangeSliderBckgrdImage.size.width, rangeSliderBckgrdImage.size.height)];
        [keywordsBackgrdImageView setUserInteractionEnabled:YES];
        [keywordsBackgrdImageView setImage:rangeSliderBckgrdImage];
        [popOverBackgroundImageView addSubview:keywordsBackgrdImageView];
        
        UILabel *keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 90, 20)];
        [keywordLabel setBackgroundColor:[UIColor clearColor]];
        [keywordLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [keywordLabel setTextAlignment:UITextAlignmentLeft];
        [keywordLabel setTextColor:[UIColor whiteColor]];
        [keywordLabel setText:@"Keywords"];
        [keywordsBackgrdImageView addSubview:keywordLabel];
        [keywordLabel release];
        
        UIImage *textFieldBackground = [UIImage imageNamed:@"keyword_inputbox.png"];
        UIImageView *textFieldBackgrdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 35, textFieldBackground.size.width, textFieldBackground.size.height)];
        [textFieldBackgrdImageView setImage:textFieldBackground];
        [keywordsBackgrdImageView addSubview:textFieldBackgrdImageView];
        [textFieldBackgrdImageView release];
        
        textField_ = [[UITextField alloc] initWithFrame:CGRectMake(12, 35, 215, 25)];
        [textField_ setUserInteractionEnabled:YES];
        [textField_ setDelegate:self];
        [textField_ setBackgroundColor:[UIColor clearColor]];
        [textField_ setPlaceholder:@"brand or model"];
        [textField_ setBorderStyle:UITextBorderStyleNone];
        [textField_ setTextColor:[UIColor whiteColor]];
        [textField_ setReturnKeyType:UIReturnKeyDone];
        [keywordsBackgrdImageView addSubview:textField_];
        [keywordsBackgrdImageView release];
                
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 325.0, popOverBackgroundImageView.frame.size.width - 40.0, 50.0)];
        [textLabel setTag:kTextLabelTag];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setNumberOfLines:3];
        [textLabel setLineBreakMode:UILineBreakModeWordWrap];
        [textLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [textLabel setTextAlignment:UITextAlignmentCenter];
        [textLabel setTextColor:[UIColor whiteColor]];
        [textLabel setText:@"Fill the above details and press ok. We will notify you, as soon as we find a matching deal."];
        [popOverBackgroundImageView addSubview:textLabel];
        [textLabel release];
        
        UIImage *cancelImage_normal = [UIImage imageNamed:@"cancel_normal.png"];
        UIImage *cancelImage_pressed = [UIImage imageNamed:@"cancel_pressed.png"];
        UIButton *cancelButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelButton setTag:kCancelButtonTag];
        [cancelButton setImage:cancelImage_normal forState:UIControlStateNormal];
        [cancelButton setImage:cancelImage_pressed forState:UIControlStateSelected];
        [cancelButton setFrame:CGRectMake(21, 390, cancelImage_normal.size.width, cancelImage_normal.size.height)];
        [cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [popOverBackgroundImageView addSubview:cancelButton];
        
        UIImage *greenImage_normal = [UIImage imageNamed:@"ok_normal.png"];
        UIImage *greenImage_pressed= [UIImage imageNamed:@"ok_pressed.png"];
        
        UIButton *okButton  = [UIButton buttonWithType:UIButtonTypeCustom];
        [okButton setTag:kOkButtonTag];
        [okButton setImage:greenImage_normal forState:UIControlStateNormal];
        [okButton setImage:greenImage_pressed forState:UIControlStateSelected];
        [okButton setFrame:CGRectMake(21+cancelImage_normal.size.width+10, 390, greenImage_normal.size.width, greenImage_normal.size.height)];
        [okButton addTarget:self action:@selector(addButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [popOverBackgroundImageView addSubview:okButton];
        
        [popOverBackgroundImageView release];

    }
    return self;
}

#pragma mark -
#pragma mark SLIDER
- (int)minPriceForCategory:(PACategory)category{
    
    switch (category) {
        case PACategory_Books:{
            return 1;
            endPrice_ = 100;
            break;
        }
        case PACategory_MP3Players:{
            return 20;
            endPrice_ = 250;
            break;
        }
        case PACategory_MobilePhones:{
            return 50;
            endPrice_ = 700;
            break;
        }
        case PACategory_Tablets:{
            return 100;
            endPrice_ = 600;
            break;
        }
        case PACategory_Laptops:{
            return 100;
            endPrice_ = 2000;
            break;
        }
        case PACategory_Cameras:{
            return 100;
            endPrice_ = 2000;
            break;
        }
        case PACategory_Shoe:{
            return 10;
            endPrice_ = 100;
            break;
        }
        case PACategory_Watches:{
            return 10;
            endPrice_ = 500;
            break;
        }
        case PACategory_Glasses:{
            return 10;
            endPrice_ = 100;
            break;
        }
            
        default:{
            return 0;
            break;
        }
    }    
}
- (int)maxPriceForCategory:(PACategory)category{
    
    switch (category) {
        case PACategory_Books:{
            return 200;
            break;
        }
        case PACategory_MP3Players:{
            return 500;
            break;
        }
        case PACategory_MobilePhones:{
            return 1000;
            break;
        }
        case PACategory_Tablets:{
            return 1000;
            break;
        }
        case PACategory_Laptops:{
            return 2000;
            break;
        }
        case PACategory_Cameras:{
            return 2000;
            break;
        }
        case PACategory_Shoe:{
            return 500;
            break;
        }
        case PACategory_Watches:{
            return 500;
            break;
        }
        case PACategory_Glasses:{
            return 500;
            break;
        }
            
        default:{
            return 1000;
            break;
        }
    }    
}
- (void)sliderValueChanged:(FCRangeSlider *)sender {
    
    int minPrice = [self minPriceForCategory:dealDetails_.category];
    int maxPrice = [self maxPriceForCategory:dealDetails_.category];
    
    startPrice_ = (int)(minPrice + ((maxPrice - minPrice)* sender.rangeValue.start)/10);
    endPrice_ = (int)(minPrice + ((maxPrice - minPrice)* sender.rangeValue.end)/10);
        
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    
    UILabel *startLabel = (UILabel *)[[popOver viewWithTag:kSliderBackgroundViewTag] viewWithTag:kStartValueLabelTag];
    UILabel *endLabel = (UILabel *)[[popOver viewWithTag:kSliderBackgroundViewTag] viewWithTag:kEndValueLabelTag];
    
    [startLabel setText:[NSString stringWithFormat:@"%$%d",startPrice_]];
    [endLabel setText:[NSString stringWithFormat:@"%$%d",endPrice_]];
}

#pragma mark - 
#pragma mark Bounce Animation
- (void)addedSuccessfully{

    // remove the add, cancel buttons and text
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    UILabel *textLabel  =  (UILabel *)[popOver viewWithTag:kTextLabelTag];
    [textLabel removeFromSuperview];
    UIButton *cancelButton = (UIButton *)[popOver viewWithTag:kCancelButtonTag];
    [cancelButton removeFromSuperview];
    UIButton *okButton = (UIButton *)[popOver viewWithTag:kOkButtonTag];    
    [okButton removeFromSuperview];
    
    // Add right mark at the position and then perform animation
    
    UIImage *addedImage = [UIImage imageNamed:@"tick.png"];
    UIImageView *addedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 330, addedImage.size.width, addedImage.size.height)];
    [addedImageView setImage:addedImage];
    [popOver addSubview:addedImageView];    
    [addedImageView release];
    
    UILabel *successTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 400.0, popOver.frame.size.width -100.0, 20.0)];
    [successTextLabel setTag:kTextLabelTag];
    [successTextLabel setBackgroundColor:[UIColor clearColor]];
    [successTextLabel setNumberOfLines:2];
    [successTextLabel setLineBreakMode:UILineBreakModeWordWrap];
    [successTextLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
    [successTextLabel setTextAlignment:UITextAlignmentCenter];
    [successTextLabel setTextColor:[UIColor whiteColor]];
    [successTextLabel setText:@"Submitted Successfully."];
    [popOver addSubview:successTextLabel];
    [successTextLabel release];
    
    [self performSelector:@selector(moveAwayTop) withObject:nil afterDelay:0.75];
    [self performSelector:@selector(removeViewFromSuperView) withObject:nil afterDelay:1.0];
}
- (void)removeViewFromSuperView{
    [self removeFromSuperview];
}
- (void)doBounceAnimation{
    
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    
    popOver.alpha = 0;
    [UIView animateWithDuration:0.1 animations:^{popOver.alpha = 1.0;}];
    
    popOver.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1.0);
    
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    bounceAnimation.values = [NSArray arrayWithObjects:
                              [NSNumber numberWithFloat:0.5],
                              [NSNumber numberWithFloat:0.8],
                              [NSNumber numberWithFloat:1.1],
                              [NSNumber numberWithFloat:1.0], nil];
    bounceAnimation.duration = 0.25;
    bounceAnimation.removedOnCompletion = NO;
    [popOver.layer addAnimation:bounceAnimation forKey:@"bounce"];
    
    popOver.layer.transform = CATransform3DIdentity;
}

#pragma mark - action handlers
- (void)cancelButtonTapped:(id)sender{    
    [delegate_ cancelClicked];

}
- (void)addButtonTapped:(id)sender{
    
    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (internetStatus == NotReachable) {

        [self showError];
    }else{
        
        PAWishDetail *wishDetail = [[PAWishDetail alloc] init];
        [wishDetail setCategory:dealDetails_.category];
        [wishDetail setStartPrice:(float)startPrice_];
        [wishDetail setEndPrice:(float)endPrice_];
        NSLog(@"text field text : %@",textField_.text);
        [wishDetail setBrandName:textField_.text];
        
        [delegate_ addWishWithDetails:wishDetail];
        [wishDetail release];    
    }
}
- (void)showError{
    // remove the add, cancel buttons and text
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    UILabel *textLabel  =  (UILabel *)[popOver viewWithTag:kTextLabelTag];
    [textLabel removeFromSuperview];
    UIButton *cancelButton = (UIButton *)[popOver viewWithTag:kCancelButtonTag];
    [cancelButton removeFromSuperview];
    UIButton *okButton = (UIButton *)[popOver viewWithTag:kOkButtonTag];    
    [okButton removeFromSuperview];
    
    // Add right mark at the position and then perform animation
    
    UIImage *addedImage = [UIImage imageNamed:@"cross.png"];
    UIImageView *addedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 330, addedImage.size.width, addedImage.size.height)];
    [addedImageView setImage:addedImage];
    [popOver addSubview:addedImageView];    
    [addedImageView release];
    
    UILabel *successTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 400.0, popOver.frame.size.width -100.0, 20.0)];
    [successTextLabel setTag:kTextLabelTag];
    [successTextLabel setBackgroundColor:[UIColor clearColor]];
    [successTextLabel setNumberOfLines:2];
    [successTextLabel setLineBreakMode:UILineBreakModeWordWrap];
    [successTextLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
    [successTextLabel setTextAlignment:UITextAlignmentCenter];
    [successTextLabel setTextColor:[UIColor whiteColor]];
    [successTextLabel setText:@"No Internet connection."];
    [popOver addSubview:successTextLabel];
    [successTextLabel release];
    
    [self performSelector:@selector(moveAwayBottom) withObject:nil afterDelay:0.75];
    [self performSelector:@selector(removeViewFromSuperView) withObject:nil afterDelay:1.0];
}
#pragma mark - move popover methods
- (void)moveAwayTop{
    [UIView beginAnimations:@"" context:@""];
    
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    CGRect popOverFrame = popOver.frame;
    popOverFrame.origin.y -= 480;
    popOver.frame = popOverFrame;
    
    [UIView commitAnimations];
}

- (void)moveAwayBottom{
    [UIView beginAnimations:@"" context:@""];
    
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    CGRect popOverFrame = popOver.frame;
    popOverFrame.origin.y += 480;
    popOver.frame = popOverFrame;
    
    [UIView commitAnimations];
}

- (void)slideUp{
    [UIView beginAnimations:@"" context:@""];
    
    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    CGRect popOverFrame = popOver.frame;
    popOverFrame.origin.y -= 150;
    popOver.frame = popOverFrame;

    [UIView commitAnimations];
}
- (void)slideDown{
    [UIView beginAnimations:@"" context:@""];

    UIImageView *popOver = (UIImageView *)[self viewWithTag:kPopOverTag];
    CGRect popOverFrame = popOver.frame;
    popOverFrame.origin.y += 150;
    popOver.frame = popOverFrame;

    [UIView commitAnimations];
}

#pragma mark - text field delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self slideUp]; 
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self slideDown];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
