//
//  PADealDetail.h
//  ProjectAcquaint
//
//  Created by Shirish Gone on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PAConstants.h"

@interface PADealDetail : NSObject
@property (nonatomic, assign) PACategory category;
@property (nonatomic, assign) NSInteger dealID;
@property (nonatomic, retain) NSString  *dealURL;
@property (nonatomic, retain) NSString  *title;
@property (nonatomic, retain) NSString  *thumbnailImageURL;
@property (nonatomic, retain) UIImage   *thumbnailImage;
@property (nonatomic, assign) float     originalPrice;
@property (nonatomic, assign) float     offerPrice;
@property (nonatomic, retain) NSString  *brandName;
@property (nonatomic, retain) NSString  *modelNumber;
@end
