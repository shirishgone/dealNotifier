//
//  PAConstants.h
//  ProjectAcquaint
//
//  Created by Shirish on 9/13/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUserId   @"id"

//#define kBestBuyAPIKey  @"45jyjgmpafdfhguxz4sakrsy"
//
//#define KBestBuyBaseUrlString   @"http://api.remix.bestbuy.com/v1/products(categoryPath.id="
//#define KBestBuyUrlSuffixString1    @"&inStoreAvailability='true')?format=json&apiKey="
//#define KBestBuyUrlSuffixString2    @"&sort=dollarSavings.desc&page="

#define kServerBase @"http://notifydeal.appspot.com/notifydeal/default/"

#define kWishDeletedNotification    @"WishDeletedFromServer"
typedef enum {
    PACategory_Books,
    // Best Buy
    PACategory_MobilePhones,
    PACategory_Tablets,
    
    PACategory_Cameras,
    PACategory_Laptops,
    PACategory_MP3Players,

    // Zappos
    PACategory_Shoe,
    PACategory_Watches,
    PACategory_Glasses

} PACategory;

typedef enum {
    PAButtonState_Normal,
    PAButtonState_Pressed

}PAButtonState;

#define WISH_HEADER_HEIGHT 45
#define kBoldFont      @"HelveticaNeue-Bold"
#define kNormalFont    @"HelveticaNeue"

#define kCategory_MP3Players    @"MP3 Players"
#define kCategory_MobilePhones  @"Mobile Phones"
#define kCategory_Cameras       @"Cameras & Camcorders"
#define kCategory_Laptops       @"Laptops & Netbook Computers"
#define kCategory_Tablets       @"Tablets"


#define kBooksString    @"Books"
#define kMP3PlayersString   @"MP3 Players"
#define kMobilePhonesString @"Mobile Phones"
#define kTabletsString  @"Tablets"
#define kLaptopsString  @"Laptops"
#define kCamerasString  @"Cameras"
#define kShoeString     @"Shoe"
#define kWatchesString  @"Watches"
#define kGlassesString  @"Glasses"


#pragma mark - assets
#define kBackgroundImage                @"main_bg.png"
#define kNavigationBarImage             @"nav_bar.png"
#define kRightBarButtonImage_normal     @"big_normal.png"
#define kRightBarButtonImage_pressed    @"big_pressed.png"
#define kWishListButtonImage_Normal     @"list_normal.png"
#define kWishListButtonImage_Pressed    @"list_pressed.png"
#define kBackButtonImage_normal         @"back_normal2.png"
#define kBackButtonImage_pressed        @"back_pressed2.png"
#define kAddWishButtonImage_normal      @"add_wish_normal.png"
#define kAddWishButtonImage_pressed     @"add_wish_pressed.png"
#define kMediumBarButtonImage_Normal    @"med_normal.png"
#define kMediumBarButtonImage_Pressed   @"med_pressed.png"

#define kWishSectionBackgroundImage     @"cell_small.png"
#define kArrowImage                     @"open_cell_top_arrow.png"
#define kEditMode_buttonUnSelectedImage @"unselected.png"
#define kEditMode_buttonSelectedImage   @"selected.png"

