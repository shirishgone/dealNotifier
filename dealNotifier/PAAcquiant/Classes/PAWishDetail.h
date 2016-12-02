//
//  PAWishDeal.h
//  PAAcquiant
//
//  Created by Shirish on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAConstants.h"

@interface PAWishDetail : NSObject
@property (nonatomic, readwrite)PACategory category;
@property (nonatomic, readwrite)float startPrice;
@property (nonatomic, readwrite)float endPrice;
@property (nonatomic, retain)NSString *brandName;
@property (nonatomic, retain)NSString *modelNumber;
@end
