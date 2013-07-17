//
//  VDFilesViewController.h
//  YandexDisk
//
//  Created by Vitaly Dyachkov on 7/13/13.
//  Copyright (c) 2013 Vitaly Dyachkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VDFilesViewController : UITableViewController

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, copy) NSString *path;

@end
