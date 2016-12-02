//
//  PAWishListViewController.h
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAWishSectionHeader.h"

@interface PAWishListViewController : UITableViewController<PAWishSectionHeaderViewDelegate>{

}
@property (nonatomic, retain) UIToolbar *bottomToolBar;
- (void)openSectionWithWishID:(NSString *)wishID;
@end
