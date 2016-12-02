//
//  PAServerManager.h
//  PAAcquiant
//
//  Created by Shirish on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAConstants.h"

@class PAWishDetail;
@interface PAServerManager : NSObject{
    
    NSURLConnection *registerConnection_;
    NSURLConnection *addWishConnection_;
}
+ (id)sharedInstance;

- (void)sendProviderDeviceToken:(NSString *)tokenString;
- (void)createWishWithDetails:(PAWishDetail *)wishDetail;
- (void)deleteWishWithWishId:(NSString *)wishId;
- (void)getAndSaveDealWithDealId:(NSString *)dealId andWishId:(NSString *)wishID;

@property (nonatomic, retain)PAWishDetail *wishAdded;
@property (nonatomic, retain)NSString *wishIdDeleted;
@property (nonatomic, retain)NSURLConnection *registerConnection;
@property (nonatomic, retain)NSURLConnection *addWishConnection;
@end
