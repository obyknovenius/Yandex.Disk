//
//  VDAppDelegate.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/11/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
