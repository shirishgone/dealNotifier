//
//  PARootViewController.m
//  PAAcquiant
//
//  Created by Shirish on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PARootViewController.h"
#import "PAExistingOffersViewController.h"
#import "PAWishListViewController.h"
#import "PAAcquiantAppDelegate.h"
#import "PAImageEditingManager.h"
#import "PAConstants.h"


#define kTileHeight 139
#define kTileWidth  107

@implementation PARootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [super dealloc];
}
#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"homescreen_bg.png"];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    [backgroundImageView setBackgroundColor:[UIColor clearColor]];
    [backgroundImageView setFrame:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [self.view addSubview:backgroundImageView];
    [backgroundImageView release];
    
    UIImage *shadowImage = [UIImage imageNamed:@"nav_bar_shadow.png"];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    [shadowImageView setBackgroundColor:[UIColor clearColor]];
    [shadowImageView setFrame:CGRectMake(0, 0, shadowImage.size.width, shadowImage.size.height)];
    [self.view addSubview:shadowImageView];
    [shadowImageView release];
    
    for (int i =0 ; i < 9; i++) {
        
        float xpos = (i%3)*(kTileWidth);
        float ypos = (i/3)*(kTileHeight);
        
        PAHomeScreenTile *categoryTile = [[PAHomeScreenTile alloc] initWithFrame:CGRectMake(xpos, ypos, kTileWidth, kTileHeight)];
        [categoryTile setDelegate:self];
        switch (i) {
            case 0:
                [categoryTile setCategory:PACategory_Books];
                break;
            case 1:
                [categoryTile setCategory:PACategory_MP3Players];
                break;
            case 2:
                [categoryTile setCategory:PACategory_MobilePhones];
                break;
            case 3:
                [categoryTile setCategory:PACategory_Tablets];
                break;
            case 4:
                [categoryTile setCategory:PACategory_Laptops];
                break;
            case 5:
                [categoryTile setCategory:PACategory_Cameras];
                break;
            case 6:
                [categoryTile setCategory:PACategory_Shoe];
                break;
            case 7:
                [categoryTile setCategory:PACategory_Watches];
                break;
            case 8:
                [categoryTile setCategory:PACategory_Glasses];
                break;
                
            default:
                break;
        }
        [self.view addSubview:categoryTile];
        [categoryTile release];
        }
       
    self.title = @"Deal Notifier";
    
    UIImage *listImage_normal = [UIImage imageNamed:kWishListButtonImage_Normal];
    UIImage *listImage_pressed = [UIImage imageNamed:kWishListButtonImage_Pressed];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:listImage_normal forState:UIControlStateNormal];
    [button setImage:listImage_pressed forState:UIControlStateSelected];
    [button addTarget:self action:@selector(showWishList:) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, listImage_normal.size.width, listImage_normal.size.height)];
    
    UIBarButtonItem *listBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = listBarButton;
    [listBarButton release];
    
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)showWishList:(id)sender{
    [[self modalViewController] dismissModalViewControllerAnimated:NO];
    
    PAWishListViewController *wishListController = [[PAWishListViewController alloc] init];
    UINavigationController *wishListNavController = [[UINavigationController alloc] initWithRootViewController:wishListController];
    [wishListController release];
    [self presentModalViewController:wishListNavController animated:YES];
    [wishListNavController release];
}
#pragma mark - categoryTile Delegate

- (void)didSelectCategory:(PACategory)category{
    PAExistingOffersViewController *offersViewController = [[PAExistingOffersViewController alloc] initWithCategory:category];
    offersViewController.category = category;
    [self.navigationController pushViewController:offersViewController animated:YES];
    [offersViewController release];
}
@end
