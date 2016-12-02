//
//  PAImageEditingManager.h
//  PAAcquiant
//
//  Created by Shirish on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PAImageEditingManager : NSObject
+ (id)sharedInstance;

- (UIImage *)imageWithoutWhiteBackground:(UIImage *)image;
- (void)setNavController:(UINavigationController *)navController WithTitleString:(NSString *)title;
- (UIImage *)resizeIconImage:(UIImage *)image;
@end
