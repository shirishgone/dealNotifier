//
//  MatchedDeal.h
//  PAAcquiant
//
//  Created by shirish gone on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MatchedDeal : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * DealID;
@property (nonatomic, retain) NSString * DealUrl;
@property (nonatomic, retain) NSString * WishID;
@property (nonatomic, retain) NSNumber * OfferPrice;
@property (nonatomic, retain) NSNumber * OriginalPrice;
@property (nonatomic, retain) NSString * Title;
@property (nonatomic, retain) NSString * ImageUrl;

@end
