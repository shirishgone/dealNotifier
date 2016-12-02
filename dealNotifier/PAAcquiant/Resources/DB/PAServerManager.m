//
//  PAServerManager.m
//  PAAcquiant
//
//  Created by Shirish on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAServerManager.h"
#import "PADBManager.h"
#import "SBJson.h"
#import "PAWishDetail.h"
#import "PAConstants.h"

// Create User
#define kCreateUser_Appendix1   @"createUser"
#define kCreateUser_Appendix2   @"udid"
#define kCreateUser_Appendix3   @"tokenId"
#define kCreateUser_Appendix4   @"bundleId"
// Add Wish
#define kAddWish_Appendix1      @"addWish"
#define kAddWish_Appendix2      @"userId"
#define kAddWish_Appendix3      @"categoryId"
#define kAddWish_Appendix4      @"minPrice"
#define kAddWish_Appendix5      @"maxPrice"
#define kAddWish_Appendix6      @"brand"

// Delete wish
#define kDeleteWish_Appendix1   @"deleteWish"
#define kDeleteWish_Appendix2   @"userId"
#define kDeleteWish_Appendix3   @"wishId"

// get deal with id
#define kGetDeal_Appendix1   @"getDealWithId"
#define kGetDeal_Appendix2   @"dealId"

#define kWishDetailObjectHandle @"WishDetail"


@implementation PAServerManager
@synthesize     wishAdded;
@synthesize     wishIdDeleted;
@synthesize     registerConnection = registerConnection_;
@synthesize     addWishConnection = addWishConnection_;

+ (id)sharedInstance
{
    static PAServerManager *_sharedInstance;
    
    if (_sharedInstance == nil)
    {
        _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}

- (void)dealloc{
       
    self.wishAdded = nil;
    self.wishIdDeleted = nil;
    
    [super dealloc];
}

#pragma mark - create user using device token string
- (void)sendProviderDeviceToken:(NSString *)tokenString {
        
    NSString *udid = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];

    NSMutableString *requestURlString = [[NSMutableString alloc] init];
    [requestURlString appendString:kServerBase];
    [requestURlString appendString:kCreateUser_Appendix1];
    [requestURlString appendFormat:@"?%@=%@",kCreateUser_Appendix2,udid];// Add UDID
    [requestURlString appendFormat:@"&%@=%@",kCreateUser_Appendix3,tokenString];// Add Token String
    [requestURlString appendFormat:@"&%@=%@",kCreateUser_Appendix4,bundleID];
        
    NSURL    *httpRequestURL       = [NSURL URLWithString:requestURlString];
    [requestURlString release];
    
    NSURLRequest *urlRequest        = [NSURLRequest requestWithURL:httpRequestURL];
    
    self.registerConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [registerConnection_ start];
}


#pragma mark - Add Wish methods
- (void)createWishWithDetails:(PAWishDetail *)wishDetail{
    
    self.wishAdded = wishDetail;
    // Get id stored in shared user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int userId = [[userDefaults objectForKey:kUserId] intValue];
        
    PADBManager *dbManager = [PADBManager sharedInstance];
    NSMutableString *requestURlString = [[NSMutableString alloc] init];
    [requestURlString appendString:kServerBase];
    [requestURlString appendString:kAddWish_Appendix1];
    [requestURlString appendFormat:@"?%@=%d",kAddWish_Appendix2,userId];
    [requestURlString appendFormat:@"&%@=%@",kAddWish_Appendix3,[dbManager categoryIDForCategory:wishDetail.category]];// Add Category id
    [requestURlString appendFormat:@"&%@=%.2f",kAddWish_Appendix4,wishDetail.startPrice];       // min price
    [requestURlString appendFormat:@"&%@=%.2f",kAddWish_Appendix5,wishDetail.endPrice];         // max price
    if (wishDetail.brandName == nil) {
        [requestURlString appendFormat:@"&%@=",kAddWish_Appendix6];     // brand name
    }else{
        [requestURlString appendFormat:@"&%@=%@",kAddWish_Appendix6,wishDetail.brandName];     // brand name
    }
    
    NSString *finalReqString = [NSString stringWithString:[requestURlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"]];

    NSURL    *httpRequestURL  = [NSURL URLWithString:finalReqString];
    [requestURlString release];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:httpRequestURL];
    
    self.addWishConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
    [addWishConnection_ start];
    
}
#pragma mark - delete wish
- (void)deleteWishWithWishId:(NSString *)wishId{
    
    self.wishIdDeleted = wishId;
    
    // Get id stored in shared user defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int userId = [[userDefaults objectForKey:kUserId] integerValue];
    
    NSMutableString *requestURlString = [[NSMutableString alloc] init];
    [requestURlString appendString:kServerBase];
    [requestURlString appendString:kDeleteWish_Appendix1];
    [requestURlString appendFormat:@"?%@=%d",kDeleteWish_Appendix2,userId];
    [requestURlString appendFormat:@"&%@=%@",kDeleteWish_Appendix3,wishId];// Add Category id

    NSURL    *httpRequestURL       = [NSURL URLWithString:requestURlString];
    [requestURlString release];
    
    NSURLRequest *urlRequest        = [NSURLRequest requestWithURL:httpRequestURL];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    /* Return Value
     The downloaded data for the URL request. Returns nil if a connection could not be created or if the download fails.
     */
    if (response == nil) {
    }
    else {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id temp = [parser objectWithData:response];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            NSString *wishId = [temp valueForKey:@"wishId"];
            [[PADBManager sharedInstance] removeWishForLocalDBWithId:wishId];
        }
        [parser release];
    }
    
    
    
//    deleteWishConnection_ = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
//    [deleteWishConnection_ start];
    
}
- (void)getAndSaveDealWithDealId:(NSString *)dealId andWishId:(NSString *)wishID{
    
    NSMutableString *requestURlString = [[NSMutableString alloc] init];
    [requestURlString appendString:kServerBase];
    [requestURlString appendString:kGetDeal_Appendix1];
    [requestURlString appendFormat:@"?%@=%@",kGetDeal_Appendix2,dealId];
    
    NSURL    *httpRequestURL       = [NSURL URLWithString:requestURlString];
    [requestURlString release]; 
    NSURLRequest *urlRequest        = [NSURLRequest requestWithURL:httpRequestURL];
    
    NSError *requestError;
    NSURLResponse *urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&requestError];
    /* Return Value
     The downloaded data for the URL request. Returns nil if a connection could not be created or if the download fails.
     */
    if (response == nil) {
    }
    else {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        id temp = [parser objectWithData:response];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            NSDictionary *tempDict = (NSDictionary *)temp;
            NSDictionary *dealDict = [[tempDict objectForKey:@"deal"] objectAtIndex:0];
            NSString *dealID = [dealDict objectForKey:@"dealId"];
            NSString *dealUrl = [dealDict objectForKey:@"dealUrl"];
            NSString *title = [dealDict objectForKey:@"titleString"];
            NSString *imageUrl = [dealDict objectForKey:@"imageUrl"];
            float offerPrice = [[dealDict objectForKey:@"offerPrice"] floatValue];
            float originalPrice = [[dealDict objectForKey:@"originalPrice"] floatValue];        
            
            NSString *wishIdString = [NSString stringWithFormat:@"%d",[wishID intValue]];
            
            
            [[PADBManager sharedInstance] insertSuggessionWithWishID:wishIdString dealId:dealID url:dealUrl offerPrice:offerPrice originalPrice:originalPrice title:title andImageUrl:imageUrl];  
            
        }
        [parser release];
    }
    
}
#pragma mark - NSURL connection delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if (connection == registerConnection_) {
    }
    else if (connection ==  addWishConnection_)
    {
    }
    else{
        
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{

    SBJsonParser *parser = [[SBJsonParser alloc] init];
    PADBManager *dataManager = [PADBManager sharedInstance];

    if (connection == registerConnection_) {
        id temp = [parser objectWithData:data];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            NSNumber *userId = [NSNumber numberWithInteger:[[temp valueForKey:@"userId"] integerValue]];
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:userId forKey:kUserId];
            [userDefaults synchronize];
        }
        self.registerConnection = nil;
    }
    else if (connection ==  addWishConnection_)
    {
        id temp = [parser objectWithData:data];
        if ([temp isKindOfClass:[NSDictionary class]]) {
            NSString *wishId = [[temp valueForKey:@"wishId"] stringValue];
            [dataManager insertWishToLocalDBWithDetails:self.wishAdded andWishId:wishId];
        }
        self.addWishConnection = nil;
    }
    [parser release]; 
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    if (connection == registerConnection_) {
    }
    else if (connection ==  addWishConnection_){
    }
    else{
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    if (connection == registerConnection_) {
        self.registerConnection = nil;
    }
    else if (connection ==  addWishConnection_){
        self.addWishConnection = nil;
    }
    else{
        
    }
}

@end
