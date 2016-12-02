//
//  PADealDetail.m
//  ProjectAcquaint
//
//  Created by Shirish Gone on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PADealDetail.h"

@implementation PADealDetail
@synthesize     category;
@synthesize     dealID;
@synthesize     title;
@synthesize     thumbnailImageURL;
@synthesize     thumbnailImage;
@synthesize     dealURL;
@synthesize     originalPrice;
@synthesize     offerPrice;
@synthesize     brandName;
@synthesize     modelNumber;
- (void)dealloc{
    
    self.dealURL = nil;
    self.title = nil;
    self.thumbnailImageURL = nil;
    self.thumbnailImage = nil;
    self.brandName = nil;
    self.modelNumber = nil;
    [super dealloc];
}

@end
