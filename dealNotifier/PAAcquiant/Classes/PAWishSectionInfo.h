//
//  PAWishListCellInfo.h
//  PAAcquiant
//
//  Created by Shirish on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Wish.h"
#import "MatchedDeal.h"
#import "PAWishSectionHeader.h"

@interface PAWishSectionInfo : NSObject

@property (assign) BOOL open;
@property (retain) Wish   *wish;
@property (retain) PAWishSectionHeader* headerView;
@property (retain) NSArray *suggestedDeals;

//@property (nonatomic,retain,readonly) NSMutableArray *rowHeights;
//
//- (NSUInteger)countOfRowHeights;
//- (id)objectInRowHeightsAtIndex:(NSUInteger)idx;
//- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx;
//- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx;
//- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject;
//- (void)getRowHeights:(id *)buffer range:(NSRange)inRange;
//- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes;
//- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes;
//- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray;

@end