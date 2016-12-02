//
//  Wish.h
//  PAAcquiant
//
//  Created by shirish gone on 10/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Wish : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * BrandName;
@property (nonatomic, retain) NSString * CategoryID;
@property (nonatomic, retain) NSString * CategoryName;
@property (nonatomic, retain) NSDate * CreatedOn;
@property (nonatomic, retain) NSString * ModelNumber;
@property (nonatomic, retain) NSNumber * PriceRangeEnd;
@property (nonatomic, retain) NSNumber * PriceRangeStart;
@property (nonatomic, retain) NSString * WishID;

@end
