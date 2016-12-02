//
//  PAWishSectionHeader.h
//  PAAcquiant
//
//  Created by Shirish on 9/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PAWishSectionHeaderViewDelegate;
@class Wish;
@interface PAWishSectionHeader : UIView

@property (nonatomic, retain) Wish *wish;
@property (nonatomic, retain) UIButton *disclosureButton;
@property (nonatomic, retain) UIButton *checkmarkButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) id <PAWishSectionHeaderViewDelegate> delegate;
@property (nonatomic, readwrite)BOOL isEditMode;

-(id)initWithFrame:(CGRect)frame wish:(Wish  *)wish section:(NSInteger)sectionNumber  suggessions:(NSInteger)suggessions isEditMode:(BOOL)isEditMode delegate:(id <PAWishSectionHeaderViewDelegate>)aDelegate;
-(void)toggleOpenWithUserAction:(BOOL)userAction;
-(void)toggleOpen:(id)sender;
@end

/*
 Protocol to be adopted by the section header's delegate; the section header tells its delegate when the section should be opened and closed.
 */
@protocol PAWishSectionHeaderViewDelegate <NSObject>

@optional
- (void)sectionHeaderView:(PAWishSectionHeader*)sectionHeaderView sectionOpened:(NSInteger)section;
- (void)sectionHeaderView:(PAWishSectionHeader*)sectionHeaderView sectionClosed:(NSInteger)section;
- (BOOL)doesRowsExistsForSection:(int)sectionNumber;
@end