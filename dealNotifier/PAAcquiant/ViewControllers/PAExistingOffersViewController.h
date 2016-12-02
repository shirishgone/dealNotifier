//
//  PAExistingOffersViewController.h
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAConstants.h"
#import "IconDownloader.h"
#import "ParseOperation.h"

@interface PAExistingOffersViewController : UITableViewController <IconDownloaderDelegate, ParseOperationDelegate>{
    PACategory category_;
    int currentPageNumber_;
    int totalResultPages_;
    
    NSMutableDictionary *imageDownloadsInProgress_; 
}

@property (nonatomic, assign)PACategory category;

@property (nonatomic, retain)NSURLConnection *dealsListConnection;
@property (nonatomic, retain)NSMutableData   *dealsListData;
@property (nonatomic, retain)NSOperationQueue   *queue;
@property (nonatomic, retain)NSMutableArray *dealsListArray;

// Image Downloader
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (id)initWithCategory:(PACategory)category;
@end
