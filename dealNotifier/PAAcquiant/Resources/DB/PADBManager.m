//
//  PAWishListManager.m
//  ProjectAcquaint
//
//  Created by Shirish on 8/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PADBManager.h"
#import <CoreData/CoreData.h>
#import "PAAcquiantAppDelegate.h"
#import "Wish.h"
#import "MatchedDeal.h"
#import "PAConstants.h"
#import "PAServerManager.h"
#import "PAWishDetail.h"

@interface  PADBManager()
- (void)insertSuggessionWithWishID:(NSString *)wishId dealId:(NSString*)dealID url:(NSString *)dealUrl offerPrice:(float)offerPrice originalPrice:(float)originalPrice title:(NSString *)title andImageUrl:(NSString *)imageUrlString;
@end


@implementation PADBManager

+ (id)sharedInstance
{
    static PADBManager *_sharedInstance;
    
    if (_sharedInstance == nil)
    {
        _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}

- (void)dealloc{
    [super dealloc];
}

#pragma mark - WISH RELATED STUFF
#pragma mark - fetch data from DB

 
- (NSArray *)fetchAllWishesFromLocalDB{
  
    PAAcquiantAppDelegate *appDelegate = (PAAcquiantAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *wishEntity = [NSEntityDescription entityForName:@"Wish" inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    [fetchReq setEntity:wishEntity];
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
    if (results) { 
        return results;
    }
    return nil;
}

- (NSArray *)fetchAllSuggestedDealsFromLocalDBForWishID:(NSString *)wishID{
    
    PAAcquiantAppDelegate *appDelegate = (PAAcquiantAppDelegate *)[[UIApplication sharedApplication] delegate];
     NSEntityDescription *wishEntity = [NSEntityDescription entityForName:@"MatchedDeal" inManagedObjectContext:appDelegate.managedObjectContext];
     
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"WishID == %@", wishID];
    [fetchReq setPredicate:predicate];
    [fetchReq setEntity:wishEntity];
     
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
     if (results) {
         return results;
     }
     return nil;
}
- (NSInteger)numberOfExistingWishes{
    
    PAAcquiantAppDelegate *appDelegate = (PAAcquiantAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSEntityDescription *wishEntity = [NSEntityDescription entityForName:@"Wish" inManagedObjectContext:appDelegate.managedObjectContext];
    
    NSFetchRequest *fetchReq = [[NSFetchRequest alloc] init];
    [fetchReq setEntity:wishEntity];
    
    NSArray *results = [appDelegate.managedObjectContext executeFetchRequest:fetchReq error:nil];
    [fetchReq release];
    if (results) {
        return [results count];
    }
    return 0;
}
#pragma mark - add suggessions
//- (void)addDeals:(NSArray *)deals forWishId:(NSString *)wishID{
//
//    for (NSDictionary *deal in deals) {
//        
//        NSString *dealID = [deal objectForKey:@"dealID"];
//        NSString *dealUrl = [deal objectForKey:@"dealUrl"];
//        NSString *title = [deal objectForKey:@"titleString"];
//        NSString *imageUrl = [deal objectForKey:@"imageUrl"];
//        float offerPrice = [[deal objectForKey:@"originalPrice"] floatValue];
//        float originalPrice = [[deal objectForKey:@"offerPrice"] floatValue];        
//        
//        [self insertSuggessionWithWishID:wishID dealId:dealID url:dealUrl offerPrice:offerPrice originalPrice:originalPrice title:title andImageUrl:imageUrl];        
//    }
//}
- (void)insertSuggessionWithWishID:(NSString *)wishId dealId:(NSString*)dealID url:(NSString *)dealUrl offerPrice:(float)offerPrice originalPrice:(float)originalPrice title:(NSString *)title andImageUrl:(NSString *)imageUrlString{
        
    PAAcquiantAppDelegate *appDelegate = (PAAcquiantAppDelegate *)[[UIApplication sharedApplication] delegate];
    MatchedDeal *suggession = [NSEntityDescription insertNewObjectForEntityForName:@"MatchedDeal" inManagedObjectContext:appDelegate.managedObjectContext];
    
    suggession.DealID = dealID;
    suggession.DealUrl = dealUrl;
    suggession.Title = title;
    suggession.OfferPrice = [NSNumber numberWithFloat:offerPrice];
    suggession.OriginalPrice = [NSNumber numberWithFloat:originalPrice];
    suggession.ImageUrl = imageUrlString;
    suggession.WishID = wishId;
    [appDelegate saveContext];   
}
#pragma mark - addWish
- (void)addWishWithDetails:(PAWishDetail *)wishDetail{
    
    PAServerManager *serverCommManager = [PAServerManager sharedInstance];
    [serverCommManager createWishWithDetails:wishDetail];  
 }

- (void)insertWishToLocalDBWithDetails:(PAWishDetail *)details andWishId:(NSString *)wishId{
    
    PAAcquiantAppDelegate *appDelegate = (PAAcquiantAppDelegate *)[[UIApplication sharedApplication] delegate];
    Wish *newWish = [NSEntityDescription insertNewObjectForEntityForName:@"Wish" inManagedObjectContext:appDelegate.managedObjectContext];
    
    newWish.WishID = wishId;
    
    newWish.CategoryID = [self categoryIDForCategory:details.category];
    newWish.CreatedOn = [NSDate date];
    
    newWish.CategoryName = [self categoryNameForCategory:details.category];
    newWish.PriceRangeStart = [NSNumber numberWithFloat:details.startPrice];
    newWish.PriceRangeEnd = [NSNumber numberWithFloat:details.endPrice];
    if (details.brandName != nil) {
        newWish.BrandName = details.brandName;
    }
    if (details.modelNumber !=nil) {
        newWish.ModelNumber = details.modelNumber;
    }
    
    [appDelegate saveContext];    
    
}
#pragma mark - delete Wish
- (void)deleteWish:(Wish *)wish
{
    PAServerManager *serverCommManager = [PAServerManager sharedInstance];
    [serverCommManager deleteWishWithWishId:wish.WishID];
}

- (void)removeWishForLocalDBWithId:(NSString *)wishId{
    
    PAAcquiantAppDelegate *appDelegate = (PAAcquiantAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *wishEntity = [NSEntityDescription entityForName:@"Wish" inManagedObjectContext:appDelegate.managedObjectContext];
	[request setEntity:wishEntity];
	
    NSPredicate *playlistFilter = [NSPredicate predicateWithFormat:@"(WishID=%d)", [wishId intValue]];
	[request setPredicate:playlistFilter];
    
	NSError *error = nil;
	NSArray *dbRecords = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    [request release];
	if (dbRecords == nil) {
		NSLog(@"Unresolved error %@ userInfo = %@", error, error.userInfo);
		abort();
	}
    
    Wish *wishObj =   [dbRecords lastObject];
    if (wishObj)
    {
        [appDelegate.managedObjectContext deleteObject:wishObj];
    }
    [appDelegate.managedObjectContext save:nil];    
}
#pragma  mark - hard coded values
- (NSString *)sectionNameForCategory:(PACategory )category{
    switch (category) {
        case PACategory_Books:{
            return @"";
            break;
        }
        case PACategory_MP3Players:{
            return @"electronics";            
            break;
        }
        case PACategory_MobilePhones:{
            return @"electronics";            
            break;
        }
        case PACategory_Tablets:{
            return @"electronics";            
            break;
        }
        case PACategory_Laptops:{
            return @"electronics";            
            break;
        }
        case PACategory_Cameras:{
            return @"electronics";
            break;
        }
        case PACategory_Shoe:{
            return @"shopping";            
            break;
        }
        case PACategory_Watches:{
            return @"shopping";            
            break;
        }
        case PACategory_Glasses:{
            return @"shopping";            
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
 
}
- (NSString *)categoryIDForCategory:(PACategory )category{
    
    switch (category) {
        case PACategory_Books:{
            return @"5";
            break;
        }
        case PACategory_MP3Players:{
            return @"4";            
            break;
        }
        case PACategory_MobilePhones:{
            return @"1";            
            break;
        }
        case PACategory_Tablets:{
            return @"6";            
            break;
        }
        case PACategory_Laptops:{
            return @"3";            
            break;
        }
        case PACategory_Cameras:{
            return @"2";
            break;
        }
        case PACategory_Shoe:{
            return @"7";            
            break;
        }
        case PACategory_Watches:{
            return @"8";            
            break;
        }
        case PACategory_Glasses:{
            return @"9";            
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
    
}

- (NSString *)categoryNameForCategory:(PACategory )category{
    
    switch (category) {
        case PACategory_Books:{
            return kBooksString;
            break;
        }
        case PACategory_MP3Players:{
            return kMP3PlayersString;            
            break;
        }
        case PACategory_MobilePhones:{
            return kMobilePhonesString;            
            break;
        }
        case PACategory_Tablets:{
            return kTabletsString;            
            break;
        }
        case PACategory_Laptops:{
            return kLaptopsString;            
            break;
        }
        case PACategory_Cameras:{
            return kCamerasString;
            break;
        }
        case PACategory_Shoe:{
            return kShoeString;            
            break;
        }
        case PACategory_Watches:{
            return kWatchesString;            
            break;
        }
        case PACategory_Glasses:{
            return kGlassesString;            
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
    
}
- (NSString *)glyphForCategory:(PACategory )category{
    switch (category) {
        case PACategory_Books:{
        return @"book_trasparent.png";
            break;
        }
        case PACategory_MP3Players:{
                return @"ipod_trasparent.png";            
            break;
        }
        case PACategory_MobilePhones:{

                return @"mobile_trasparent.png";            
            break;
        }
        case PACategory_Tablets:{
 
                return @"ipad_trasparent.png";            
            break;
        }
        case PACategory_Laptops:{

                return @"laptop_trasparent.png";            
            break;
        }
        case PACategory_Cameras:{
          
                return @"camera_trasparent.png";
            break;
        }
        case PACategory_Shoe:{
          
                return @"shoes_trasparent.png";            
            break;
        }
        case PACategory_Watches:{
         
                return @"watch_trasparent.png";            
            break;
        }
        case PACategory_Glasses:{
           
                return @"shades_trasparent.png";            
            break;
        }
        default:{
            return nil;
            break;
        }
    }
}
- (NSString *)glyphForCategoryName:(NSString *)category{
    if ([category isEqualToString:kBooksString]) {
        return @"books2.png";
    }
    else if ([category isEqualToString:kMP3PlayersString]){
        return @"mp3players2.png";            
    }
    else if ([category isEqualToString:kMobilePhonesString]){
        return @"mobiles2.png";            
    }
    else if ([category isEqualToString:kTabletsString]){
        return @"tablets2.png";            
    }
    else if ([category isEqualToString:kLaptopsString]){
        return @"laptop2.png";            
    }
    else if ([category isEqualToString:kCamerasString]){
        return @"camera2.png";
    }
    else if ([category isEqualToString:kShoeString]){
        return @"shoes2.png";            
    }
    else if ([category isEqualToString:kWatchesString]){
        return @"watches2.png";            
    }
    else if ([category isEqualToString:kGlassesString]){
        return @"glasses2.png";            
    }

    else{
        return nil;
    }
}

- (NSString *)tileImageForCategory:(PACategory )category{
    switch (category) {
        case PACategory_Books:{
                
            return @"books.png";
            break;
        }
        case PACategory_MP3Players:{
                
            return @"mp3players.png";            
            break;
        }
        case PACategory_MobilePhones:{
            
            return @"mobiles.png";            
            break;
        }
        case PACategory_Tablets:{
            
            return @"tablets.png";            
            break;
        }
        case PACategory_Laptops:{
            
            return @"laptops.png";            
            break;
        }
        case PACategory_Cameras:{
            
            return @"cameras.png";
            break;
        }
        case PACategory_Shoe:{
            
            return @"shoes.png";            
            break;
        }
        case PACategory_Watches:{
            
            return @"watches.png";            
            break;
        }
        case PACategory_Glasses:{
            
            return @"glasses.png";            
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
}
- (NSString *)categoryImageInAddWishForCategory:(PACategory )category{
    switch (category) {
        case PACategory_Books:{
            
            return @"books3.png";
            break;
        }
        case PACategory_MP3Players:{
            
            return @"mp3players3.png";            
            break;
        }
        case PACategory_MobilePhones:{
            
            return @"mobiles3.png";            
            break;
        }
        case PACategory_Tablets:{
            
            return @"tablets3.png";            
            break;
        }
        case PACategory_Laptops:{
            
            return @"laptops3.png";            
            break;
        }
        case PACategory_Cameras:{
            
            return @"cameras3.png";
            break;
        }
        case PACategory_Shoe:{
            
            return @"shoes3.png";            
            break;
        }
        case PACategory_Watches:{
            
            return @"watches3.png";            
            break;
        }
        case PACategory_Glasses:{
            
            return @"glasses3.png";            
            break;
        }
            
        default:{
            return nil;
            break;
        }
    }
}


@end
