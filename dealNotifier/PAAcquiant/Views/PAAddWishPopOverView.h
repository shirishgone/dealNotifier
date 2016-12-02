//
//  PAAddWishPopOverView.h
//  ProjectAcquaint
//
//  Created by Shirish on 8/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAConstants.h"
#import "PADealDetail.h"
#import "PAWishDetail.h"

@protocol PAWishPopOverViewDelegate <NSObject>
- (void)cancelClicked;
- (void)addWishWithDetails:(PAWishDetail *)wishDetail;
@end

@class PATile;
@class FCRangeSlider;
@interface PAAddWishPopOverView : UIView <UITextFieldDelegate>{
    id <PAWishPopOverViewDelegate> delegate_;
    PADealDetail *dealDetails_;
    FCRangeSlider *slider_;

    UITextField *textField_;
    int startPrice_;
    int endPrice_;
}
@property (nonatomic, assign)id <PAWishPopOverViewDelegate> delegate;
- (void)addedSuccessfully;
- (void)doBounceAnimation;
- (void)showError;
- (id)initWithFrame:(CGRect)frame andDealDetails:(PADealDetail *)dealDetails andDelegate:(id)delegate;
@end
