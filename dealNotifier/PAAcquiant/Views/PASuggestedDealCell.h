//
//  PASuggestedDealCell.h
//  PAAcquiant
//
//  Created by Shirish on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchedDeal.h"

@interface PASuggestedDealCell : UITableViewCell

@property (nonatomic, retain)MatchedDeal *matcheddeal;
- (void)setBackgroundImageForIndex:(NSUInteger)index;
@end
