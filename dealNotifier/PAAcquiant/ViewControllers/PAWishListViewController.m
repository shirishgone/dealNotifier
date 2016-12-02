//
//  PAWishListViewController.m
//  PAAcquiant
//
//  Created by Shirish on 9/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAWishListViewController.h"
#import "PADBManager.h"
#import "PASuggestedDealCell.h"
#import "Wish.h"
#import "PAWishSectionInfo.h"
#import "PAServerManager.h"
#import "PAWebViewController.h"
#import "MatchedDeal.h"
#import "PAImageEditingManager.h"
#import "Reachability.h"

#define kRowHeight 70
#define kSuggestedDealsRowHeight 90

#define kNoWishesLogoImageViewTag   100
#define kNoWishesLabelTag   101
#define kBottomToolBarTag   102



@interface PAWishListViewController()
- (void)addNoWishesLogo;
- (void)removeNoWishesLogo;
- (void)removeAllRowsinAllSections;
- (void)showEditControlBar:(BOOL)show;
- (void)reloadWishesFromLocalDB;
@property (nonatomic, retain) NSMutableArray* sectionInfoArray;
@property (nonatomic, assign) NSInteger openSectionIndex;
@end

#define DEFAULT_ROW_HEIGHT 78

@implementation PAWishListViewController
@synthesize sectionInfoArray=sectionInfoArray_, openSectionIndex=openSectionIndex_, bottomToolBar;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.sectionInfoArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
- (void)dealloc{
    
    self.sectionInfoArray = nil;
    self.bottomToolBar = nil;
    [super dealloc];
}
#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 460-44) style:UITableViewStylePlain];
    [tableView setRowHeight:kRowHeight];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView = tableView;
    [tableView release];
    
    UIImage *backgroundImage = [UIImage imageNamed:kBackgroundImage];
    [self.navigationController.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];

    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    self.title = @"Wish List";
    
    UIImage *cancelButtonImage_normal   = [UIImage imageNamed:@"cancel_nav_normal.png"];
    UIImage *cancelButtonImage_pressed   = [UIImage imageNamed:@"cancel_nav_pressed.png"];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:cancelButtonImage_normal forState:UIControlStateNormal];
    [cancelButton setImage:cancelButtonImage_pressed forState:UIControlStateSelected];
    [cancelButton addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setFrame:CGRectMake(0, 0, cancelButtonImage_normal.size.width, cancelButtonImage_normal.size.height)];
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithCustomView:cancelButton];
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    [cancelBarButton release];
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    UIToolbar *toolBar = (UIToolbar *)[self.navigationController.view viewWithTag:kBottomToolBarTag];
    [toolBar removeFromSuperview];
    
    UIImage *barImage = [UIImage imageNamed: @"bottom_bar.png"];
    self.bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 480 - barImage.size.height, barImage.size.width, barImage.size.height)];
    
    UIImage *deleteImage    = [UIImage imageNamed:@"delete_normal.png"];
    UIButton *deleteButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteButton setBackgroundColor:[UIColor clearColor]];
    [deleteButton setFrame:CGRectMake(0, 0, deleteImage.size.width, deleteImage.size.height)];
    [deleteButton setImage:[UIImage imageNamed:@"delete_normal.png"] forState:UIControlStateNormal];
    [deleteButton setImage:[UIImage imageNamed:@"delete_pressed.png"] forState:UIControlStateSelected];
    [deleteButton addTarget:self action:@selector(deleteWishesSelected:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *deleteBarButton = [[UIBarButtonItem alloc] initWithCustomView:deleteButton];
    
    
    UIImage *selectAllImage    = [UIImage imageNamed:@"selectall_normal.png"];
    UIButton *selectAllButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllButton setBackgroundColor:[UIColor clearColor]];
    [selectAllButton setFrame:CGRectMake(0, 0, selectAllImage.size.width, selectAllImage.size.height)];
    [selectAllButton setImage:[UIImage imageNamed:@"selectall_normal.png"] forState:UIControlStateNormal];
    [selectAllButton setImage:[UIImage imageNamed:@"selectall_pressed.png"] forState:UIControlStateSelected];
    [selectAllButton addTarget:self action:@selector(selectAllClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectAllBarButton = [[UIBarButtonItem alloc] initWithCustomView:selectAllButton];
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [self.bottomToolBar setItems:[NSArray arrayWithObjects:flexiSpace,deleteBarButton,flexiSpace,selectAllBarButton,flexiSpace, nil]];
    [flexiSpace release];
    [selectAllBarButton release];
    [deleteBarButton release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    openSectionIndex_ = NSNotFound;
    [self reloadWishesFromLocalDB];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)wishesDeletedNotificationHanlder{
    [self reloadWishesFromLocalDB];
    [self.tableView reloadData];
}
- (void)reloadWishesFromLocalDB{
    PADBManager *dbManager = [PADBManager sharedInstance];
    NSArray *wishes = [NSArray arrayWithArray:[dbManager fetchAllWishesFromLocalDB]];
    
    
    if ([wishes count] == 0) {
        // Add no wishes label
        [self addNoWishesLogo];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } 
    else{
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self removeNoWishesLogo];
        
        [self.sectionInfoArray removeAllObjects];
       // if ((self.sectionInfoArray == nil) || ([self.sectionInfoArray count] != [self numberOfSectionsInTableView:self.tableView])) {
            
            // For each play, set up a corresponding SectionInfo object to contain the default height for each row.
            NSMutableArray *infoArray = [[NSMutableArray alloc] init];
            
            for (Wish *wish in wishes) {
                
                PAWishSectionInfo *sectionInfo = [[PAWishSectionInfo alloc] init];			
                sectionInfo.wish = wish;
                sectionInfo.open = NO;
                
               // NSNumber *defaultRowHeight = [NSNumber numberWithInteger:DEFAULT_ROW_HEIGHT];
                
                PADBManager *dataManager = [PADBManager sharedInstance];
                NSArray *suggestedDeals  = [dataManager fetchAllSuggestedDealsFromLocalDBForWishID:wish.WishID];
                
                sectionInfo.suggestedDeals = suggestedDeals;
                
//                NSInteger countOfQuotations = [suggestedDeals count];
//                for (NSInteger i = 0; i < countOfQuotations; i++) {
//                    [sectionInfo insertObject:defaultRowHeight];// inRowHeightsAtIndex:i];
//                }
                
                [infoArray addObject:sectionInfo];
                [sectionInfo release];
            }
            
            [sectionInfoArray_ addObjectsFromArray:infoArray];
            [infoArray release];
        //}
        [self.tableView reloadData];
        
    }    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [self removeNoWishesLogo];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - CUSTOM UI
#pragma mark - bar buttons

- (UIBarButtonItem *)editButtonItem{
    
    UIImage *barButtonImage_normal   = [UIImage imageNamed:@"edit_normal.png"];
    UIImage *barButtonImage_pressed   = [UIImage imageNamed:@"edit_pressed.png"];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [editButton setImage:barButtonImage_normal forState:UIControlStateNormal];
    [editButton setImage:barButtonImage_pressed forState:UIControlStateSelected];
    [editButton addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
    [editButton setFrame:CGRectMake(0, 0, barButtonImage_normal.size.width, barButtonImage_normal.size.height)];
    
    UIBarButtonItem *editBarButton = [[[UIBarButtonItem alloc] initWithCustomView:editButton] autorelease];
    return editBarButton;
    
}
- (UIBarButtonItem *)doneBarButtonItem{
    
    UIImage *barButtonImage_normal   = [UIImage imageNamed:@"done_normal.png"];
    UIImage *barButtonImage_pressed   = [UIImage imageNamed:@"done_pressed.png"];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setImage:barButtonImage_normal forState:UIControlStateNormal];
    [doneButton setImage:barButtonImage_pressed forState:UIControlStateSelected];
    [doneButton addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(0, 0, barButtonImage_normal.size.width, barButtonImage_normal.size.height)];
    
    UIBarButtonItem *doneBarButton = [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease];
    return doneBarButton;
    
}
#pragma mark - no wishes Logo and label methods
- (void)addNoWishesLogo{
    
    UILabel *noWishesLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 180, 290, 150)];
    [noWishesLabel setTag:kNoWishesLabelTag];
    [noWishesLabel setBackgroundColor:[UIColor clearColor]];
    [noWishesLabel setTextColor:[UIColor colorWithRed:(80/255.0) green:(80/255.0) blue:(80/255.0) alpha:1.0]];
    [noWishesLabel setTextAlignment:UITextAlignmentCenter];
    [noWishesLabel setLineBreakMode:UILineBreakModeWordWrap];
    [noWishesLabel setNumberOfLines:10];
    [noWishesLabel setFont:[UIFont fontWithName:kBoldFont size:18]];
    [noWishesLabel setText:@"No wishes. Please add your wishes by tapping addwish in product list. We will notify you, as soon as we find a matching deal for a wish."];
    [self.navigationController.view addSubview:noWishesLabel];
    [noWishesLabel release];
    
}
- (void)removeNoWishesLogo{
    UIImageView *noWishesImageView = (UIImageView *)[self.navigationController.view  viewWithTag:kNoWishesLogoImageViewTag];
    if (noWishesImageView != nil) {
        [noWishesImageView removeFromSuperview];
    }
    
    UILabel *noWishesLabel = (UILabel *)[self.navigationController.view  viewWithTag:kNoWishesLabelTag];
    if (noWishesLabel != nil) {
        [noWishesLabel removeFromSuperview];
    }
}
#pragma mark - action Handlers
- (void)cancelClicked:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)editClicked:(id)sender{
        [self.tableView setEditing:YES animated:YES];
        
        [self removeAllRowsinAllSections];
        [self showEditControlBar:YES];
        self.navigationItem.rightBarButtonItem = [self doneBarButtonItem];
        
        [self.tableView reloadData];
}
- (void)doneClicked:(id)sender{
    
    [self.tableView setEditing:NO animated:YES];
    
    [self showEditControlBar:NO];
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];    
    [self.tableView reloadData];
    
    if ([self.sectionInfoArray count] == 0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self addNoWishesLogo];
    }
}

#pragma mark - custom methods
- (void)removeAllRowsinAllSections{
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
    
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    for (int i =0; i < [self.sectionInfoArray count]; i++) {
        PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:i];
        
        sectionInfo.open = NO;
        NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:i]; 
        if (countOfRowsToDelete > 0) {
            
            for (NSInteger j = 0; j < countOfRowsToDelete; j++) {
                [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:j inSection:i]];
            }
        }
    }
    
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    [indexPathsToDelete release];
    self.openSectionIndex = NSNotFound;
    
}

- (void)showEditControlBar:(BOOL)show{

    [self.bottomToolBar removeFromSuperview];
    if (show == YES) {
        [self.navigationController.view addSubview:self.bottomToolBar];
    }
}

- (void)selectAllClicked:(id)sender{
    
    // Get all the Views and respective state
    int sections = [self numberOfSectionsInTableView:self.tableView];
    
    for (int i =0; i < sections; i++) {
        PAWishSectionHeader *sectionHeader  =  (PAWishSectionHeader *)[self tableView:self.tableView viewForHeaderInSection:i];
        sectionHeader.checkmarkButton.selected = YES;
    }
    [self.tableView reloadData];

    UIImage *selectnoneImage    = [UIImage imageNamed:@"selectnone_normal.png"];
    UIButton *selectnoneButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectnoneButton setBackgroundColor:[UIColor clearColor]];
    [selectnoneButton setFrame:CGRectMake(0, 0, selectnoneImage.size.width, selectnoneImage.size.height)];
    [selectnoneButton setImage:[UIImage imageNamed:@"selectnone_normal.png"] forState:UIControlStateNormal];
    [selectnoneButton setImage:[UIImage imageNamed:@"selectnone_pressed.png"] forState:UIControlStateSelected];
    [selectnoneButton addTarget:self action:@selector(selectNoneClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectNoneButton = [[UIBarButtonItem alloc] initWithCustomView:selectnoneButton];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.bottomToolBar.items];
    [items replaceObjectAtIndex:3 withObject:selectNoneButton];
    [self.bottomToolBar setItems:items];
    [items release];
    [selectNoneButton release];
}

- (void)selectNoneClicked:(id)sender{
    
    // Get all the Views and respective state
    int sections = [self numberOfSectionsInTableView:self.tableView];
    
    for (int i =0; i < sections; i++) {
        PAWishSectionHeader *sectionHeader  =  (PAWishSectionHeader *)[self tableView:self.tableView viewForHeaderInSection:i];
        sectionHeader.checkmarkButton.selected = NO;
    }
    [self.tableView reloadData];
    
    
    UIImage *selectAllImage    = [UIImage imageNamed:@"selectall_normal.png"];
    UIButton *selectAllButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectAllButton setBackgroundColor:[UIColor clearColor]];
    [selectAllButton setFrame:CGRectMake(0, 0, selectAllImage.size.width, selectAllImage.size.height)];
    [selectAllButton setImage:[UIImage imageNamed:@"selectall_normal.png"] forState:UIControlStateNormal];
    [selectAllButton setImage:[UIImage imageNamed:@"selectall_pressed.png"] forState:UIControlStateSelected];
    [selectAllButton addTarget:self action:@selector(selectAllClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *selectAllBarButton = [[UIBarButtonItem alloc] initWithCustomView:selectAllButton];
    
    NSMutableArray *items = [[NSMutableArray alloc] initWithArray:self.bottomToolBar.items];
    [items replaceObjectAtIndex:3 withObject:selectAllBarButton];
    [self.bottomToolBar setItems:items];
    [items release];
    [selectAllBarButton release];
    
}
- (void)deleteWishesSelected:(id)sender{

    NetworkStatus internetStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No internet connection."
                                                            message:@"Sorry, you cant delete wishes without a connection."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];

    }else{        
        PAServerManager *serverManager = [PAServerManager sharedInstance];
        int sections = [self numberOfSectionsInTableView:self.tableView];
        
        NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
        
        for (int i =0; i < sections; i++) {
            PAWishSectionHeader *sectionHeader  =  (PAWishSectionHeader *)[self tableView:self.tableView viewForHeaderInSection:i];
            if (sectionHeader.checkmarkButton.selected == YES) {
                PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:i];
                [serverManager deleteWishWithWishId:sectionInfo.wish.WishID];
                [indexSet addIndex:i];
                //[self.sectionInfoArray removeObjectAtIndex:i];
            }
        }
        [self.sectionInfoArray removeObjectsAtIndexes:indexSet];
        [self.tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
    }
    
    
}
#pragma mark - tableView datasources
#pragma mark Table view data source and delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return [self.sectionInfoArray count];
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    
	PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
	NSInteger numStoriesInSection = [sectionInfo.suggestedDeals count];
	
    return sectionInfo.open ? numStoriesInSection : 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SuggestedDealCell";
    
    PASuggestedDealCell *cell = (PASuggestedDealCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[PASuggestedDealCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]  autorelease];
    }
    [cell setBackgroundImageForIndex:indexPath.row];
    PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
    cell.matcheddeal = [sectionInfo.suggestedDeals objectAtIndex:indexPath.row];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
    /*
     Create the section header views lazily.
     */
	PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:section];
    Wish *wish = sectionInfo.wish;

    if (sectionInfo.headerView == nil) {
        sectionInfo.headerView = [[[PAWishSectionHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, WISH_HEADER_HEIGHT) wish:wish section:section suggessions:[sectionInfo.suggestedDeals count] isEditMode:tableView.isEditing  delegate:self] autorelease];
    }
    PAWishSectionHeader *sectionHeader = sectionInfo.headerView;
    [sectionHeader setIsEditMode:tableView.isEditing];
    [sectionHeader setWish:wish];
    
    return sectionInfo.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return  kRowHeight;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  kSuggestedDealsRowHeight;
}

#pragma mark - table view delegate

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
    PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
    MatchedDeal *deal = [sectionInfo.suggestedDeals objectAtIndex:indexPath.row];
    
    PAWebViewController *webViewController = [[[PAWebViewController alloc] init] autorelease];
    [webViewController setFromWishesView:YES];
    [webViewController setUrlString:deal.DealUrl];
    //[webViewController setDealDetails:MatchedDeal];
    [self.navigationController pushViewController:webViewController animated:YES];    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO || !indexPath)
    {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *) indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // remove the row here.
    }
}

#pragma mark Section header delegate
- (BOOL)doesRowsExistsForSection:(int)sectionNumber{
    PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionNumber];
    int rows = [sectionInfo.suggestedDeals count];
    if (rows >0) {
        return YES;
    }
    else{
        return NO;
    }
}
-(void)sectionHeaderView:(PAWishSectionHeader*)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
	
	PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionOpened];
	
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSArray *suggestedDeals  = sectionInfo.suggestedDeals;

    
    NSInteger countOfRowsToInsert = [suggestedDeals count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
//    /*
//     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
//     */
  
    NSInteger previousOpenSectionIndex = self.openSectionIndex;

    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
    }
    
    // Apply the updates.
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.tableView endUpdates];
    self.openSectionIndex = sectionOpened;
    
    [indexPathsToInsert release];
}


-(void)sectionHeaderView:(PAWishSectionHeader*)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:sectionClosed];
	
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        [indexPathsToDelete release];
    }
    self.openSectionIndex = NSNotFound;
}


- (void)refreshTable{
    [self.tableView reloadData];
}

- (void)openSectionWithWishID:(NSString *)wishID{
    
    for (int i =0; i< [self.sectionInfoArray count]; i++) {
        PAWishSectionInfo *sectionInfo = [self.sectionInfoArray objectAtIndex:i];
        Wish *wish = sectionInfo.wish;
        if ([wish.WishID isEqualToString:wishID]) {
            [sectionInfo.headerView toggleOpen:nil]; 
        }
    }
}
@end
