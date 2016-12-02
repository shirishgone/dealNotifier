/*
     File: ParseOperation.m 
 Abstract: NSOperation code for parsing the RSS feed.
  
  Version: 1.2 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2010 Apple Inc. All Rights Reserved. 
  
 */

#import "ParseOperation.h"
#import "PADealDetail.h"
#import "SBJson.h"

// string contants found in the RSS feed
static NSString *kDealID = @"dealId";
static NSString *kDealUrl = @"dealUrl";
static NSString *kDealTitle = @"titleString";
static NSString *kDealImageUrl = @"imageUrl";
static NSString *kDealOriginalPrice = @"originalPrice";
static NSString *kDealSalePrice = @"offerPrice";


@interface ParseOperation ()
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) PADealDetail *workingEntry;
@property (nonatomic, retain) NSMutableString *workingPropertyString;
@property (nonatomic, retain) NSArray *elementsToParse;
@property (nonatomic, assign) BOOL storingCharacterData;
@end

@implementation ParseOperation

@synthesize delegate, dataToParse, workingArray, workingEntry, workingPropertyString, elementsToParse, storingCharacterData, category;

- (id)initWithData:(NSData *)data delegate:(id <ParseOperationDelegate>)theDelegate
{
    self = [super init];
    if (self != nil)
    {
        self.dataToParse = data;
        self.delegate = theDelegate;
        self.elementsToParse = [NSArray arrayWithObjects:kDealID, kDealUrl, kDealTitle, kDealImageUrl, kDealOriginalPrice, kDealSalePrice, nil];
                
    }
    return self;
}
// -------------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [dataToParse release];
    [workingEntry release];
    [workingPropertyString release];
    [workingArray release];
    
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	main:
//  Given data to parse, use NSXMLParser and process all the top paid apps.
// -------------------------------------------------------------------------------
- (void)main
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	self.workingArray = [NSMutableArray array];

    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id temp = [parser objectWithData:dataToParse];
    
    if (temp == nil) {
        [parser release];
        [pool release];
        [delegate noItemsFound];
        return;
    }
    if ([temp isKindOfClass:[NSDictionary class]]) {
        NSDictionary *totalDataDict = (NSDictionary *)temp;
        int currentPage   =   [[totalDataDict objectForKey:@"currentPage"]intValue];
        int totalPages    =   [[totalDataDict objectForKey:@"totalPages"]intValue];
        [delegate totalPages:totalPages andPresentPageNumber:currentPage];
        
        NSArray *items = [totalDataDict objectForKey:@"products"];
        
        if ([items count] == 0) {
            [parser release];
            [pool release];
            [delegate noItemsFound];
            return;
        }
        for (NSDictionary *product in items) {  
            self.workingEntry = [[[PADealDetail alloc] init] autorelease];
            
            self.workingEntry.category         = self.category;
            self.workingEntry.dealID           = [[product objectForKey:kDealID] intValue]; // check if it is not NSNUll
            self.workingEntry.dealURL          = [product objectForKey:kDealUrl];
            self.workingEntry.title            = [product objectForKey:kDealTitle];
            self.workingEntry.thumbnailImageURL= [product objectForKey:kDealImageUrl];
            self.workingEntry.originalPrice    = [[product objectForKey:kDealOriginalPrice] floatValue];
            self.workingEntry.offerPrice       = [[product objectForKey:kDealSalePrice] floatValue];
            
            [self.workingArray addObject:self.workingEntry];
            self.workingEntry = nil;
        }

        
    }else{
        [parser release];
        [pool release];
        [delegate parseErrorOccurred:nil];
        return; 
    }
    
    if (![self isCancelled])
    {
        // notify our AppDelegate that the parsing is complete
        [self.delegate didFinishParsing:self.workingArray];
    }
    self.workingArray = nil;
    self.workingPropertyString = nil;
    self.dataToParse = nil;
     
    [parser release];
    [pool release]; 

}
@end