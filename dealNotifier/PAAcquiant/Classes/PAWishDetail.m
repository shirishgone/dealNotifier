//
//  PAWishDeal.m
//  PAAcquiant
//
//  Created by Shirish on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAWishDetail.h"

@implementation PAWishDetail
@synthesize    category;
@synthesize    startPrice;
@synthesize    endPrice;
@synthesize    brandName;
@synthesize    modelNumber;
- (void)dealloc{
    
    self.brandName = nil;
    self.modelNumber = nil;
    [super dealloc];
}
@end
