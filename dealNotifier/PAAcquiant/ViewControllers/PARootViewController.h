//
//  PARootViewController.h
//  PAAcquiant
//
//  Created by Shirish on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAHomeScreenTile.h"

@interface PARootViewController : UIViewController<PAHomeScreenTileDelegate>
- (void)showWishList:(id)sender;
@end
