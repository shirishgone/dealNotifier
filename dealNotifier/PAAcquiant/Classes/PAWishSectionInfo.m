//
//  PAWishListCellInfo.m
//  PAAcquiant
//
//  Created by Shirish on 9/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAWishSectionInfo.h"



@implementation PAWishSectionInfo

@synthesize open , wish, headerView, suggestedDeals;//rowHeights

//- init {
//	
//	self = [super init];
//	if (self) {
//		rowHeights = [[NSMutableArray alloc] init];
//	}
//	return self;
//}
//
//
//- (NSUInteger)countOfRowHeights {
//	return [rowHeights count];
//}
//
//- (void)getRowHeights:(id *)buffer range:(NSRange)inRange {
//	[rowHeights getObjects:buffer range:inRange];
//}
//
//- (id)objectInRowHeightsAtIndex:(NSUInteger)idx {
//	return [rowHeights objectAtIndex:idx];
//}
//
//- (void)insertObject:(id)anObject inRowHeightsAtIndex:(NSUInteger)idx {
//	[rowHeights insertObject:anObject atIndex:idx];
//}
//
//- (void)insertRowHeights:(NSArray *)rowHeightArray atIndexes:(NSIndexSet *)indexes {
//	[rowHeights insertObjects:rowHeightArray atIndexes:indexes];
//}
//
//- (void)removeObjectFromRowHeightsAtIndex:(NSUInteger)idx {
//	[rowHeights removeObjectAtIndex:idx];
//}
//
//- (void)removeRowHeightsAtIndexes:(NSIndexSet *)indexes {
//	[rowHeights removeObjectsAtIndexes:indexes];
//}
//
//- (void)replaceObjectInRowHeightsAtIndex:(NSUInteger)idx withObject:(id)anObject {
//	[rowHeights replaceObjectAtIndex:idx withObject:anObject];
//}
//
//- (void)replaceRowHeightsAtIndexes:(NSIndexSet *)indexes withRowHeights:(NSArray *)rowHeightArray {
//	[rowHeights replaceObjectsAtIndexes:indexes withObjects:rowHeightArray];
//}


- (void)dealloc {
    self.wish = nil;
    self.headerView = nil;
    self.suggestedDeals = nil;
	[super dealloc];
}

@end