//
//  DealDetailsCell.m
//  Acquaint
//
//  Created by Shirish Gone on 15/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DealDetailsCell.h"
#include <QuartzCore/CoreAnimation.h>
#include "PAStrikeThroughLabel.h"
#include "PAImageEditingManager.h"
#import "NSString+HTML.h"
#import "PAConstants.h"

#define kCellHeight 90

#define kImageMaxHeight 70
#define kImageMaxWidth  70

#define kDealImageViewTag   200
#define kDealTitleLabelTag  201
#define kContainerViewTag   206
#define kDealSavePercentLabelTag    203
#define kDealOriginalPriceLabelTag  204
#define kDealOfferPriceLabelTag 205

#define kDealImageFrame CGRectMake(10, 20, 56, 50)
#define kTitleFrame CGRectMake(100, 5, 195, 40)

#define kOriginalPriceFrame    CGRectMake(100, 55, 70, 20)
#define kOfferPriceFrame   CGRectMake(190, 55, 70, 20)

#define kCellBackgroundImage    @"cell_big.png"

#define kRibbonImageViewTag 222

@implementation DealDetailsCell
@synthesize     dealID;
@synthesize     dealUrl;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, 320, kCellHeight);
        self.userInteractionEnabled = YES;
        
        UIImage *backgroundImage = [UIImage imageNamed:kCellBackgroundImage];
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
        [backgroundImageView setFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
        [self.contentView addSubview:backgroundImageView];
        [backgroundImageView release];
        
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
        [titleLabel setBackgroundColor:[UIColor clearColor]];
        [titleLabel setFont:[UIFont fontWithName:kNormalFont size:14]];
        [titleLabel setTextColor:[UIColor colorWithRed:(63/255.0) green:(63/255.0) blue:(63/255.0) alpha:1.0]];
        [self.contentView addSubview:titleLabel];
        [titleLabel release];

        PAStrikeThroughLabel *originalPriceValueLabel = [[PAStrikeThroughLabel alloc] initWithFrame:kOriginalPriceFrame];
        [originalPriceValueLabel setBackgroundColor:[UIColor clearColor]];
        [originalPriceValueLabel setTextAlignment:UITextAlignmentLeft];
        [originalPriceValueLabel setFont:[UIFont fontWithName:kNormalFont size:16]];
        [originalPriceValueLabel setTextColor:[UIColor colorWithRed:(167.0/255.0) green:(67.0/255.0) blue:(67.0/255.0) alpha:1.0]];
        originalPriceValueLabel.tag=kDealOriginalPriceLabelTag;
        [self.contentView addSubview:originalPriceValueLabel];
        [originalPriceValueLabel release];
        
        UILabel *offerPriceValueLabel = [[UILabel alloc] initWithFrame:kOfferPriceFrame];
        [offerPriceValueLabel setBackgroundColor:[UIColor clearColor]];
        [offerPriceValueLabel setTextAlignment:UITextAlignmentLeft];
        [offerPriceValueLabel setFont:[UIFont fontWithName:kNormalFont size:16]];
        [offerPriceValueLabel setTextColor:[UIColor colorWithRed:(68.0/255.0) green:(117.0/255.0) blue:(64.0/255.0) alpha:1.0]];
        offerPriceValueLabel.tag = kDealOfferPriceLabelTag;
        [self.contentView addSubview:offerPriceValueLabel];
        [offerPriceValueLabel release];
        
        UIImage *arrow = [UIImage imageNamed:@"arrow.png"];
        UIImageView *accesoryImageView = [[UIImageView alloc] initWithImage:arrow];
        [accesoryImageView setBackgroundColor:[UIColor clearColor]];
        [accesoryImageView setFrame:CGRectMake(0, 0, arrow.size.width, arrow.size.height)];
        self.accessoryView = accesoryImageView;
        [accesoryImageView release];

        
    }
    return self;
}

#pragma mark - setting cell Details
- (void)setDealImage:(UIImage *)dealImage isPlaceHolder:(BOOL)isPlaceHolder{

    if (dealImage != nil) {
        UIImageView *dealImageView  = (UIImageView *)[[self.contentView viewWithTag:kContainerViewTag] viewWithTag:kDealImageViewTag];
        float xPos = (80 - dealImage.size.width)/2;
        float yPos = (81 - dealImage.size.height)/2;
        
        [dealImageView setFrame:CGRectMake(xPos, yPos, dealImage.size.width, dealImage.size.height)];
        [dealImageView setImage:dealImage];
    }
}

- (void)setDealTitle:(NSString *)dealTitle{
    UILabel *dealTitleLabel  = (UILabel *)[self.contentView viewWithTag:kDealTitleLabelTag];
    [dealTitleLabel setText:[dealTitle stringByConvertingHTMLToPlainText]];
}

- (void)setOriginalPrice:(float)originalPrice andOfferPrice:(float)offerPrice
{

    if (originalPrice == offerPrice) {
        UILabel *originalPriceLabel  = (UILabel *)[self.contentView viewWithTag:kDealOriginalPriceLabelTag];
        [originalPriceLabel setHidden:YES];
        
        UILabel *offerPriceLabel  = (UILabel *)[self.contentView viewWithTag:kDealOfferPriceLabelTag];
        [offerPriceLabel setFrame:kOriginalPriceFrame];
        [offerPriceLabel setText:[NSString stringWithFormat:@"$%.2f",offerPrice]];        
        
    }else{
        NSString *originalString = [NSString stringWithFormat:@"$%.2f",originalPrice];
        CGSize originalStringSize = [originalString sizeWithFont:[UIFont fontWithName:kNormalFont size:16] constrainedToSize:CGSizeMake(200, 25)];
        
        UILabel *originalPriceLabel  = (UILabel *)[self.contentView viewWithTag:kDealOriginalPriceLabelTag];
        [originalPriceLabel setFrame:CGRectMake(originalPriceLabel.frame.origin.x, originalPriceLabel.frame.origin.y, originalStringSize.width, originalPriceLabel.frame.size.height)];
        [originalPriceLabel setHidden:NO];
        [originalPriceLabel setText:[NSString stringWithFormat:@"$%.2f",originalPrice]];
                
        UILabel *offerPriceLabel  = (UILabel *)[self.contentView viewWithTag:kDealOfferPriceLabelTag];
        [offerPriceLabel setFrame:kOfferPriceFrame];
        [offerPriceLabel setText:[NSString stringWithFormat:@"$%.2f",offerPrice]];
        
    }
}
- (void)dealloc{
    
    self.dealUrl = nil;
    [super dealloc];
}
@end
