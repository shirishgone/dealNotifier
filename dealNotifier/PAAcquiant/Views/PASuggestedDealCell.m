//
//  PASuggestedDealCell.m
//  PAAcquiant
//
//  Created by Shirish on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PASuggestedDealCell.h"
#include <QuartzCore/CoreAnimation.h>
#import "PAStrikeThroughLabel.h"
#import "PAConstants.h"
#import "PAImageEditingManager.h"
#import "NSString+HTML.h"

#define  kCellBackgroundImage   @"category_open_cell_big.png"

#define kDealImageViewTag   200
#define kDealTitleLabelTag  201
#define kDealSavePercentLabelTag    203
#define kDealOriginalPriceLabelTag  204
#define kDealOfferPriceLabelTag 205
#define kBackgroundImageViewTag 206
#define kContainerViewTag   207

#define kDealImageFrame CGRectMake(0, 0, 70, 70)
#define kTitleFrame CGRectMake(100, 5, 195, 40)
#define kOriginalPriceFrame    CGRectMake(100, 50, 85, 20)
#define kOfferPriceFrame   CGRectMake(190, 50, 85, 20)

@implementation PASuggestedDealCell
@synthesize     matcheddeal;

- (void)dealloc{
    self.matcheddeal = nil;
    [super dealloc];
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code        
        self.userInteractionEnabled = YES;
        
        UIImage *backgroundImage = [UIImage imageNamed:@"open_cell_top.png"];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [backgroundImageView setTag:kBackgroundImageViewTag];
        float xPos = 0;
        float yPos = 0;
        [backgroundImageView setFrame:CGRectMake(xPos, yPos, backgroundImage.size.width, backgroundImage.size.height)];
        [self.contentView addSubview:backgroundImageView];
        
        UIImage *containerImage = [UIImage imageNamed:@"image_placeholder.png"];
        UIImageView *iconContainerView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, containerImage.size.width, containerImage.size.height)];
        [iconContainerView setImage:containerImage];
        [iconContainerView setBackgroundColor:[UIColor clearColor]];
        iconContainerView.tag   = kContainerViewTag;
        [self.contentView addSubview:iconContainerView];
        
        UIImageView *dealImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, containerImage.size.width, containerImage.size.height)];
        [dealImageView setBackgroundColor:[UIColor clearColor]];
        dealImageView.tag   = kDealImageViewTag;
        [iconContainerView addSubview:dealImageView];
        [dealImageView release];
        [iconContainerView release];
        

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:kTitleFrame];
        titleLabel.tag = kDealTitleLabelTag;
        titleLabel.numberOfLines = 2;
        [titleLabel setTextAlignment:UITextAlignmentLeft];
        [titleLabel setTextColor:[UIColor colorWithRed:(226.0/255.0) green:(226.0/255.0) blue:(226.0/255.0) alpha:1.0]];
        [titleLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [backgroundImageView addSubview:titleLabel];
        [titleLabel release];
        
        PAStrikeThroughLabel *originalPriceValueLabel = [[PAStrikeThroughLabel alloc] initWithFrame:kOriginalPriceFrame];
        [originalPriceValueLabel setBackgroundColor:[UIColor clearColor]];
        [originalPriceValueLabel setTextAlignment:UITextAlignmentLeft];
        [originalPriceValueLabel setFont:[UIFont fontWithName:kNormalFont size:16]];
        [originalPriceValueLabel setTextColor:[UIColor colorWithRed:(167.0/255.0) green:(67.0/255.0) blue:(67.0/255.0) alpha:1.0]];
        originalPriceValueLabel.tag = kDealOriginalPriceLabelTag;
        [backgroundImageView addSubview:originalPriceValueLabel];
        [originalPriceValueLabel release];
        
        UILabel *offerPriceValueLabel = [[UILabel alloc] initWithFrame:kOfferPriceFrame];
        [offerPriceValueLabel setBackgroundColor:[UIColor clearColor]];
        [offerPriceValueLabel setTextAlignment:UITextAlignmentLeft];
        [offerPriceValueLabel setFont:[UIFont fontWithName:kNormalFont size:16]];
        [offerPriceValueLabel setTextColor:[UIColor colorWithRed:(64.0/255.0) green:(156.0/255.0) blue:(57.0/255.0) alpha:1.0]];
        offerPriceValueLabel.tag = kDealOfferPriceLabelTag;
        [backgroundImageView addSubview:offerPriceValueLabel];
        [offerPriceValueLabel release];
        [backgroundImageView release];
        
        UIImage *arrow = [UIImage imageNamed:@"arrow_white.png"];
        UIImageView *accesoryImageView = [[UIImageView alloc] initWithImage:arrow];
        [accesoryImageView setBackgroundColor:[UIColor clearColor]];
        [accesoryImageView setFrame:CGRectMake(0, 0, arrow.size.width, arrow.size.height)];
        self.accessoryView = accesoryImageView;
        [accesoryImageView release];

    }
    return self;
}
- (void)setBackgroundImageForIndex:(NSUInteger)index{
    UIImage *backgroundImage;
    if (index ==0) {
        backgroundImage = [UIImage imageNamed:@"open_cell_top.png"];
    }
    else{
        backgroundImage = [UIImage imageNamed:@"open_cell_bottom.png"];
    }

    UIImageView *backgroundImageView = (UIImageView *)[self.contentView viewWithTag:kBackgroundImageViewTag];
    [backgroundImageView setImage:backgroundImage];
}

- (void)setMatcheddeal:(MatchedDeal *)tempMatcheddeal{
    matcheddeal = tempMatcheddeal;
    
    UIImageView *backgroundImageView = (UIImageView *)[self.contentView viewWithTag:kBackgroundImageViewTag];
    
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:tempMatcheddeal.ImageUrl]]];
    UIImageView *dealImageView  = (UIImageView *)[[self.contentView viewWithTag:kContainerViewTag] viewWithTag:kDealImageViewTag];
    UIImage *scaledImage = [[PAImageEditingManager sharedInstance] resizeIconImage:image];
    //[dealImageView setImage:scaledImage];
    
    if (scaledImage != nil) {
        float xPos = (80 - scaledImage.size.width)/2;
        float yPos = (81 - scaledImage.size.height)/2;
        
        [dealImageView setFrame:CGRectMake(xPos, yPos, scaledImage.size.width, scaledImage.size.height)];
        [dealImageView setImage:scaledImage];
    }else{
        dealImageView = nil;
    }
    
    UILabel *dealTitleLabel  = (UILabel *)[backgroundImageView viewWithTag:kDealTitleLabelTag];
    [dealTitleLabel setText:[tempMatcheddeal.Title stringByConvertingHTMLToPlainText]];
    
    NSString *originalString = [NSString stringWithFormat:@"$%.2f",[tempMatcheddeal.OriginalPrice floatValue]];
    CGSize originalStringSize = [originalString sizeWithFont:[UIFont fontWithName:kNormalFont size:16] constrainedToSize:CGSizeMake(200, 25)];
    
    UILabel *originalPriceLabel  = (UILabel *)[backgroundImageView viewWithTag:kDealOriginalPriceLabelTag];
    [originalPriceLabel setFrame:CGRectMake(originalPriceLabel.frame.origin.x, originalPriceLabel.frame.origin.y, originalStringSize.width, originalPriceLabel.frame.size.height)];
    [originalPriceLabel setText:[NSString stringWithFormat:@"$%.2f",[tempMatcheddeal.OriginalPrice floatValue]]];
    
    UILabel *offerPriceLabel  = (UILabel *)[backgroundImageView viewWithTag:kDealOfferPriceLabelTag];
    [offerPriceLabel setText:[NSString stringWithFormat:@"$%.2f",[tempMatcheddeal.OfferPrice floatValue]]];
}

@end
