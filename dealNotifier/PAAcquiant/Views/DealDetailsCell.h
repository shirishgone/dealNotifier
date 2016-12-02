//
//  DealDetailsCell.h
//  Acquaint
//
//  Created by Shirish Gone on 15/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DealDetailsCell : UITableViewCell
@property (nonatomic, assign)NSInteger dealID;
@property (nonatomic, retain)NSString *dealUrl;
- (void)setDealImage:(UIImage *)dealImage isPlaceHolder:(BOOL)isPlaceHolder;
- (void)setDealTitle:(NSString *)dealTitle;
- (void)setOriginalPrice:(float)originalPrice andOfferPrice:(float)offerPrice;
@end
