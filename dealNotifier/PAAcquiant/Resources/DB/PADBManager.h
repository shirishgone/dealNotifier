//
//  PAWishListManager.h
//  ProjectAcquaint
//
//  Created by Shirish on 8/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAConstants.h"
@class Wish;
@class PAWishDetail;
@interface PADBManager : NSObject

+ (id)sharedInstance;

- (NSString *)glyphForCategoryName:(NSString *)category;
- (NSString *)glyphForCategory:(PACategory )category;
- (NSString *)sectionNameForCategory:(PACategory )category;
- (NSString *)categoryIDForCategory:(PACategory )category;
- (NSString *)categoryNameForCategory:(PACategory )category;
//- (NSString *)imageNameForCategory:(PACategory )category;

// Wish Related Methods
- (void)addWishWithDetails:(PAWishDetail *)wishDetail;
- (void)insertWishToLocalDBWithDetails:(PAWishDetail *)details andWishId:(NSString *)wishId;
- (NSInteger)numberOfExistingWishes;
- (void)deleteWish:(Wish *)wish;
- (void)removeWishForLocalDBWithId:(NSString *)wishId;

- (NSArray *)fetchAllWishesFromLocalDB;
- (NSArray *)fetchAllSuggestedDealsFromLocalDBForWishID:(NSString *)wishID;

- (NSString *)tileImageForCategory:(PACategory )category;
- (NSString *)categoryImageInAddWishForCategory:(PACategory )category;

//- (void)addDeals:(NSArray *)deals forWishId:(NSString *)wishID;
- (void)insertSuggessionWithWishID:(NSString *)wishId dealId:(NSString*)dealID url:(NSString *)dealUrl offerPrice:(float)offerPrice originalPrice:(float)originalPrice title:(NSString *)title andImageUrl:(NSString *)imageUrlString;
@end
