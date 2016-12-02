//
//  PAExistingOffersViewController.m
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAExistingOffersViewController.h"
#import "PADBManager.h"
#import "PADealDetail.h"
#import "PAWebViewController.h"
#import "DealDetailsCell.h"
#import "PAAddWishPopOverView.h"
#import "PAConstants.h"

#define kRowHeight  90
#define kAddWishPopOverTag  100

#define kNoDealsLabelTag    101
#define kNoDealsLogoImageViewTag    102
#define kMaxPages   5

@interface PAExistingOffersViewController()
- (void)cancelClicked;
- (void)addNoDealsLogo;
- (void)removeNoDealsLogo;
- (void)fetchDealsWithPageNumber:(int)pageNumber;
- (void)startIconDownload:(PADealDetail *)dealDetail forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation PAExistingOffersViewController
@synthesize     category = category_;

@synthesize     dealsListConnection;
@synthesize     dealsListData;
@synthesize     queue;
@synthesize     dealsListArray;
@synthesize     imageDownloadsInProgress = imageDownloadsInProgress_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithCategory:(PACategory)category{
    
    self = [super init];
    if (self) {
        category_ = category;
        currentPageNumber_ = 1;
        totalResultPages_ = 1;
        
        [self.tableView setRowHeight:kRowHeight];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        self.dealsListArray = [[[NSMutableArray alloc] init] autorelease];
        self.imageDownloadsInProgress = [[[NSMutableDictionary alloc] init] autorelease];
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
}

- (void)dealloc{
    
    if (self.dealsListConnection !=nil) {
        [dealsListConnection cancel]; self.dealsListConnection = nil;
    }
    if (self.dealsListData != nil) {
        self.dealsListData = nil;
    }
    if (self.queue !=nil) {
        self.queue = nil;
    }
    if (self.dealsListArray !=nil) {
        self.dealsListArray = nil;
    }
    [imageDownloadsInProgress_ release];
    
    [super dealloc];
}
#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // Navigation bar buttons
    UIImage *backButtonImage_normal   = [UIImage imageNamed:@"home_normal.png"];
    UIImage *backButtonImage_pressed   = [UIImage imageNamed:@"home_pressed.png"];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, backButtonImage_normal.size.width, backButtonImage_normal.size.height)];
    [backButton setImage:backButtonImage_normal forState:UIControlStateNormal];
    [backButton setImage:backButtonImage_pressed forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [backButton.titleLabel setFont:[UIFont fontWithName:kBoldFont size:12]];
    [backButton.titleLabel setTextAlignment:UITextAlignmentRight];
    [backButton setTitleColor:[UIColor colorWithRed:(45/255.0) green:(49/255.0) blue:(51/255.0) alpha:1.0] forState:UIControlStateNormal];
    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
    [backBarButton release];
    
    UIImage *addButtonImage_normal   = [UIImage imageNamed:kAddWishButtonImage_normal];
    UIImage *addButtonImage_pressed   = [UIImage imageNamed:kAddWishButtonImage_pressed];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setFrame:CGRectMake(0, 0, addButtonImage_normal.size.width, addButtonImage_normal.size.height)];
    [addButton setImage:addButtonImage_normal forState:UIControlStateNormal];
    [addButton setImage:addButtonImage_pressed forState:UIControlStateHighlighted];
    [addButton addTarget:self action:@selector(addWishButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *addBarButton = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = addBarButton;
    [addBarButton release];
    
    
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    PADBManager *dataManager = [PADBManager sharedInstance];
    self.title = [dataManager categoryNameForCategory:category_];
    
    [self fetchDealsWithPageNumber:currentPageNumber_];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self cancelClicked];
    [self removeNoDealsLogo];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark - bar button action handlers
- (void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)addWishButtonTapped:(id)sender{
    // check wishes. More than 5 cant be allowed.
    NSInteger wishCount = [[PADBManager sharedInstance] numberOfExistingWishes];
    if (wishCount >= 5) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Sorry, you cant add more than 5 wishes. Please remove any of your wish from the WishList and proceed adding new wishes." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    PADealDetail *tempDealDetails = [[PADealDetail alloc] init];
    [tempDealDetails setCategory:category_];
    
    PAAddWishPopOverView *addWishView = [[PAAddWishPopOverView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) andDealDetails:tempDealDetails andDelegate:self];
    addWishView.tag = kAddWishPopOverTag;
    [self.navigationController.view addSubview:addWishView];
    [self.view setUserInteractionEnabled:NO];
    [addWishView doBounceAnimation];
    [addWishView release];
    [tempDealDetails release];
    
}
- (void)cancelClicked{
    PAAddWishPopOverView *addWishView = (PAAddWishPopOverView *)[self.navigationController.view viewWithTag:kAddWishPopOverTag];
    [addWishView removeFromSuperview];
    [self.view setUserInteractionEnabled:YES];
}

- (void)addWishWithDetails:(PAWishDetail *)wishDetail{
    // add the wish
    wishDetail.modelNumber = nil;
    
    PADBManager *dataManager = [PADBManager sharedInstance];
    [dataManager addWishWithDetails:wishDetail];
    
    // Remove the view from the super view
    PAAddWishPopOverView *addWishView = (PAAddWishPopOverView *)[self.navigationController.view viewWithTag:kAddWishPopOverTag];
    [addWishView addedSuccessfully];
    [self.view setUserInteractionEnabled:YES];
}
#pragma mark - no wishes Logo and label methods
- (void)addNoDealsLogo{
    
//    UIImage *noWishesLogo = [UIImage imageNamed:@"add_logo.png"];
//    UIImageView *noWishesImageView = [[UIImageView alloc] initWithImage:noWishesLogo];
//    [noWishesImageView setTag:kNoDealsLogoImageViewTag];
//    [noWishesImageView setFrame:CGRectMake((320-noWishesLogo.size.width)/2, (460 -44 - noWishesLogo.size.height)/2-50, noWishesLogo.size.width, noWishesLogo.size.height)];
//    [self.view addSubview:noWishesImageView];
//    [noWishesImageView release];
    
    UILabel *noWishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 110, 290, 150)];
    [noWishesLabel setTag:kNoDealsLabelTag];
    [noWishesLabel setBackgroundColor:[UIColor clearColor]];
    [noWishesLabel setTextColor:[UIColor colorWithRed:(80/255.0) green:(80/255.0) blue:(80/255.0) alpha:1.0]];
    [noWishesLabel setTextAlignment:UITextAlignmentCenter];
    [noWishesLabel setLineBreakMode:UILineBreakModeWordWrap];
    [noWishesLabel setNumberOfLines:10];
    [noWishesLabel setFont:[UIFont fontWithName:kBoldFont size:18]];
    [noWishesLabel setText:@"Sorry, Presently we dont have any deals to show. Please add your wishes by tapping addwish, we will notify you when we find a match for you wishes."];
    [self.view addSubview:noWishesLabel];
    [noWishesLabel release];
    
    
}
- (void)removeNoDealsLogo{
    
    UIImageView *noWishesImageView = (UIImageView *)[self.view viewWithTag:kNoDealsLogoImageViewTag];
    if (noWishesImageView != nil) {
        [noWishesImageView removeFromSuperview];
    }
    
    UILabel *noWishesLabel = (UILabel *)[self.view viewWithTag:kNoDealsLabelTag];
    if (noWishesLabel != nil) {
        [noWishesLabel removeFromSuperview];
    }
}
#pragma mark - table view datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dealsListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    DealDetailsCell *cell = (DealDetailsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[DealDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    id obj = [self.dealsListArray objectAtIndex:indexPath.row];
    if ([obj isKindOfClass:[PADealDetail class]]) {
        PADealDetail *dealDetail = [self.dealsListArray objectAtIndex:indexPath.row];
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!dealDetail.thumbnailImage)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:dealDetail forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            [cell setDealImage:[UIImage imageNamed:[[PADBManager sharedInstance] glyphForCategory:self.category]] isPlaceHolder:YES];
        }
        else
        {
            [cell setDealImage:dealDetail.thumbnailImage isPlaceHolder:NO];
        }
        [cell setDealUrl:dealDetail.dealURL];
        [cell setDealTitle:dealDetail.title];
        [cell setOriginalPrice:dealDetail.originalPrice andOfferPrice:dealDetail.offerPrice];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    PADealDetail *dealDetail = [self.dealsListArray objectAtIndex:indexPath.row];
    PAWebViewController *webViewController = [[[PAWebViewController alloc] init] autorelease];
    [webViewController setUrlString:dealDetail.dealURL];
    [self.navigationController pushViewController:webViewController animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return  kRowHeight;
}

#pragma mark - get Deals
- (void)fetchDealsWithPageNumber:(int)pageNumber{
    
    PADBManager *dataManager = [PADBManager sharedInstance];
    
    //getdeals
    NSMutableString *requestString = [[NSMutableString alloc] init];
    [requestString appendString:kServerBase];
    [requestString appendString:@"getDeals"];
    [requestString appendFormat:@"?categoryID=%@",[dataManager categoryIDForCategory:category_]];
    [requestString appendFormat:@"&page=%d",pageNumber];
    [requestString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *url = [NSURL URLWithString:requestString];
    [requestString release];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    
    self.dealsListConnection = [[[NSURLConnection alloc] initWithRequest:req delegate:self] autorelease];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
- (void)handleError:(NSError *)error
{
//    self.dealsListArray = nil;
//    self.dealsListData = nil;
//    self.dealsListConnection = nil;
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There seems to be some problem with internet connection"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
    
}

#pragma mark - connection delegates
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.dealsListData = [NSMutableData data];    // start off with new data
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [dealsListData appendData:data];  // append incoming data
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.dealsListConnection = nil;   // release our connection
    
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.dealsListConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    self.queue = [[[NSOperationQueue alloc] init] autorelease];
    ParseOperation *parser = [[ParseOperation alloc] initWithData:dealsListData delegate:self];
    parser.category = category_;
    [queue addOperation:parser]; // this will start the "ParseOperation"
    self.dealsListData = nil;
    [parser release];
    
}
#pragma mark - parser delegates
- (void)didFinishParsing:(NSArray *)dealsList
{
    [self performSelectorOnMainThread:@selector(handleLoadedDeals:) withObject:dealsList waitUntilDone:NO];
    
    self.queue = nil;   // we are finished with the queue and our ParseOperation
}

- (void)noItemsFound{
    
    [self addNoDealsLogo];
}
- (void)parseErrorOccurred:(NSError *)error
{
    [self performSelectorOnMainThread:@selector(handleError:) withObject:error waitUntilDone:NO];
}
- (void)handleLoadedDeals:(NSArray *)dealsList
{
    [self.dealsListArray addObjectsFromArray:dealsList];
    
    [self.tableView reloadData];
    
}
- (void)totalPages:(int)pagesCount andPresentPageNumber:(int)pageNumber{
    //currentPageNumber_ = pageNumber;
    totalResultPages_ = pagesCount;
}

#pragma mark -
#pragma mark Table cell image support

- (void)startIconDownload:(PADealDetail *)dealDetail forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress_ objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.dealDetail = dealDetail;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress_ setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
        
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.dealsListArray count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            PADealDetail *dealDetail = [self.dealsListArray objectAtIndex:indexPath.row];
            
            if (!dealDetail.thumbnailImage) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:dealDetail forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)dealImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress_ objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        DealDetailsCell *cell = (DealDetailsCell *)[self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        [cell setDealImage:iconDownloader.dealDetail.thumbnailImage isPlaceHolder:NO];
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ((currentPageNumber_ < totalResultPages_) && (currentPageNumber_ < kMaxPages) && (currentPageNumber_*10 <=[self.dealsListArray count])) {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        float reload_distance = 10;
        if(y > h + reload_distance) {
            [self fetchDealsWithPageNumber:++currentPageNumber_];
        }
    }
    
}
// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //[super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //[super scrollViewDidEndDecelerating:scrollView];
    
    [self loadImagesForOnscreenRows];
}

@end
