//
//  PAAcquiantAppDelegate.h
//  PAAcquiant
//
//  Created by Shirish on 9/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface PAAcquiantAppDelegate : NSObject <UIApplicationDelegate>{
    
    UINavigationController *_rootNavigationController;
}

@property (nonatomic, readwrite)BOOL registered;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@end
