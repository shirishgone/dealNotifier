//
//  PAWebViewController.m
//  ProjectAcquaint
//
//  Created by Shirish Gone on 31/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAWebViewController.h"
#import "PAConstants.h"
#import "PAImageEditingManager.h"
#import "Reachability.h"

#define kAddWishPopOverTag 100
#define kBottomBarTag   101
#define kBackButtonTag  102
#define kRightButtonTag   103
#define kWebViewTag 104

@interface PAWebViewController()
- (void)refreshBottomBarButtons;
@end

@implementation PAWebViewController
@synthesize     urlString;
@synthesize     fromWishesView = fromWishesView_;

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
    UIWebView *webView = (UIWebView *)[self.view viewWithTag:kWebViewTag];
    [webView removeFromSuperview];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
- (void)dealloc{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.urlString = nil;
    [super dealloc];
}
#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor clearColor];
    
    self.title = @"Details";
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 460-44-44)];
    [webView setTag:kWebViewTag];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    [webView release];
    
    // Navigation bar buttons
    UIImage *backButtonImage_normal;
    UIImage *backButtonImage_pressed;
    
    if (fromWishesView_ == YES) {
        backButtonImage_normal= [UIImage imageNamed:@"wishes_normal.png"];
    }else{
        backButtonImage_normal= [UIImage imageNamed:@"products_normal.png"];
    }
    if (fromWishesView_ == YES) {
        backButtonImage_pressed= [UIImage imageNamed:@"wishes_pressed.png"];
    }else{
        backButtonImage_pressed= [UIImage imageNamed:@"products_pressed.png"];
    }
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, backButtonImage_normal.size.width, backButtonImage_normal.size.height)];
    [backButton setImage:backButtonImage_normal forState:UIControlStateNormal];
    [backButton setImage:backButtonImage_pressed forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];    
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backBarButton;
    [backBarButton release];
    
    
    UIImage *barImage = [UIImage imageNamed: @"bottom_bar.png"];
    UIToolbar *bottomToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 460 - barImage.size.height-44, barImage.size.width, barImage.size.height)];
    bottomToolBar.tag = kBottomBarTag;
    
    UIImage *leftImage    = [UIImage imageNamed:@"arrow_left.png"];
    UIButton *leftButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundColor:[UIColor clearColor]];
    [leftButton setFrame:CGRectMake(0, 0, leftImage.size.width, leftImage.size.height)];
    [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"arrow_left.png"] forState:UIControlStateSelected];
    [leftButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    [leftBarButton setTag:kBackButtonTag];
    
    UIImage *rightImage    = [UIImage imageNamed:@"arrow_right.png"];
    UIButton *rightButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setBackgroundColor:[UIColor clearColor]];
    [rightButton setFrame:CGRectMake(0, 0, rightImage.size.width, rightImage.size.height)];
    [rightButton setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"arrow_right.png"] forState:UIControlStateSelected];
    [rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    [rightBarButton setTag:kRightButtonTag];
    
    UIBarButtonItem *flexiSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [bottomToolBar setItems:[NSArray arrayWithObjects:flexiSpace,leftBarButton,flexiSpace,rightBarButton,flexiSpace, nil]];
    [flexiSpace release];
    [leftBarButton release];
    [rightBarButton release];
    
    [self.view addSubview:bottomToolBar];
    [bottomToolBar release];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    UIWebView *webView = (UIWebView *)[self.view viewWithTag:kWebViewTag];
    [webView loadRequest:urlRequest];
}


- (void)viewDidUnload
{
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - swipe gesture handlers
- (void)leftButtonClicked:(id)sender
{
    UIWebView *webView = (UIWebView *)[self.view viewWithTag:kWebViewTag];
    if ([webView canGoBack]) {
        [webView goBack];
    }    
}
- (void)rightButtonClicked:(id)sender
{
    UIWebView *webView = (UIWebView *)[self.view viewWithTag:kWebViewTag];
    if ([webView canGoForward]) {
        [webView goForward];
    }
}
- (void)refreshBottomBarButtons{
    
    UIWebView *webView = (UIWebView *)[self.view viewWithTag:kWebViewTag];
    UIToolbar *bottomBar = (UIToolbar *)[self.view viewWithTag:kBottomBarTag];
    UIBarButtonItem *backButton = [[bottomBar items] objectAtIndex:1];
    UIBarButtonItem *rightButton = [[bottomBar items] objectAtIndex:3];
    
    
    if ([webView canGoBack]) {
        [backButton setEnabled:YES];
    }else{
        [backButton setEnabled:NO];
    }
    if ([webView canGoForward]) {
        [rightButton setEnabled:YES];
    }else{
        [rightButton setEnabled:NO];
    }
}
#pragma mark - back button action
- (void)backButtonTapped:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - web View Delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    Reachability* internetReachable;
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    [internetReachable release];
    if (internetStatus == NotReachable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"There seems to be some problem with internet connection"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self refreshBottomBarButtons];    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self refreshBottomBarButtons];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self refreshBottomBarButtons];
}

@end
