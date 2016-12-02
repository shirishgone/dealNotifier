//
//  PAImageEditingManager.m
//  PAAcquiant
//
//  Created by Shirish on 10/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PAImageEditingManager.h"
#include <QuartzCore/CoreAnimation.h>
#import "PAConstants.h"
#define kMaxImageHeight  76.0
#define kMaxImageWidth  76.0

@implementation UINavigationBar (UINavigationBarCategory)
- (void) drawRect:(CGRect)rect {
    if (self.translucent == NO) {
        UIImage *barImage = [UIImage imageNamed:kNavigationBarImage];
        [barImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}

- (void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3
    // For iOS 5
    if([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        UIImage *barImage = [UIImage imageNamed:kNavigationBarImage];
        [self setBackgroundImage:barImage forBarMetrics:UIBarMetricsDefault];
    }
#endif
    
}
@end

@implementation UIToolbar (UIToolBarCategory)
- (void) drawRect:(CGRect)rect {
    if (self.translucent == NO) {
        UIImage *barImage = [UIImage imageNamed:@"bottom_bar.png"];
        [barImage drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    }
}
- (void) willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3
    
    if([self respondsToSelector:@selector(setBackgroundImage:forToolbarPosition:barMetrics:)] ) {
        //iOS 5 new UINavigationBar custom background
        UIImage *barImage = [UIImage imageNamed:@"bottom_bar.png"];
        [self setBackgroundImage:barImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    }
#endif
}

@end

@implementation PAImageEditingManager

+ (id)sharedInstance
{
    static PAImageEditingManager *_sharedInstance;
    
    if (_sharedInstance == nil)
    {
        _sharedInstance = [[self alloc] init];
    }
    
    return _sharedInstance;
}

- (UIImage *)imageWithoutWhiteBackground:(UIImage *)image{
    
    CGImageRef rawImageRef=image.CGImage;
    const float colorMasking[6] = {222, 255, 222, 255, 222, 255};
    
    UIGraphicsBeginImageContext(image.size);
    CGImageRef maskedImageRef=CGImageCreateWithMaskingColors(rawImageRef, colorMasking);
    {
        
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0.0, image.size.height);
        CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0); 
    }
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, image.size.width, image.size.height), maskedImageRef);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(maskedImageRef);
    UIGraphicsEndImageContext();    
    return result;
}

#pragma mark - setNavigation colors

- (void)setNavController:(UINavigationController *)navController WithTitleString:(NSString *)title{
    
    id tempTitleLabel =  navController.navigationItem.titleView;
    
    if ([tempTitleLabel isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)tempTitleLabel;
        
        [titleLabel setTextColor:[UIColor redColor]];
        [titleLabel setText:title];
    
    }
}

- (UIImage *)resizeIconImage:(UIImage *)image{
    
    if (image.size.height > kMaxImageHeight && image.size.width > kMaxImageWidth) {
        // Resize the image to fit in the cell
        float scale;
        if ((image.size.width - kMaxImageWidth) > (image.size.height - kMaxImageHeight)) {
            scale =  kMaxImageWidth/image.size.width;
        }else{
            scale =  kMaxImageHeight/image.size.height;
        }
        
        CGSize newSize = CGSizeMake(image.size.width *scale, image.size.height*scale);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage*scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return  scaledImage;
    }else if (image.size.height > kMaxImageHeight ) {
        // Resize the image to fit in the cell
        
        // check how much more and resize accordingly 
        float scale =  kMaxImageHeight/image.size.height;
        
        CGSize newSize = CGSizeMake(image.size.width *scale, image.size.height*scale);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage*scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return  scaledImage;
    }
    else if (image.size.width > kMaxImageWidth){
        
        // Resize the image to fit in the cell
        // check how much more and resize accordingly 
        float scale =  kMaxImageWidth/image.size.width;
        
        CGSize newSize = CGSizeMake(image.size.width *scale, image.size.height*scale);
        UIGraphicsBeginImageContext(newSize);
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        UIImage*scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return  scaledImage;    
    }
    else
    {
        return  image;
    }
}

@end
