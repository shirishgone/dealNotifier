//
//  PAWebViewController.h
//  ProjectAcquaint
//
//  Created by Shirish Gone on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAConstants.h"

@class PADealDetail;
@interface PAWebViewController : UIViewController <UIWebViewDelegate>{
    BOOL fromWishesView_;
}
@property (nonatomic, retain)NSString *urlString;
@property (nonatomic, readwrite)BOOL fromWishesView;
@end
