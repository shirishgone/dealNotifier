//
//  PAHomeScreenTile.h
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAConstants.h"

@class PAHomeScreenTile;
@protocol PAHomeScreenTileDelegate <NSObject>
- (void)didSelectCategory:(PACategory)category;
@end

@interface PAHomeScreenTile : UIView{
@private
    id <PAHomeScreenTileDelegate> delegate_;
    PACategory category_;
}

@property (nonatomic, assign)id <PAHomeScreenTileDelegate> delegate;
@property (nonatomic, assign)PACategory category;
@end
